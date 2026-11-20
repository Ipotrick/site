---
title: "Practical, Efficient Rendergraphs"
date: 2026-11-20
draft: false
---

A rendergraph (or frame graph) describes a frame as a set of passes and the resources they read and write, instead of a hand-ordered list of API calls. The renderer declares *what* it wants, and the graph works out *how* to execute it: ordering, barriers, memory, and what can be skipped.

This post covers what a rendergraph needs to do to be useful in practice, and where the cost hides.

## The core idea

Each frame is built in two phases:

1. **Declare.** Passes are registered with the resources they read and write. Nothing runs yet.
2. **Compile and execute.** The graph is analysed, then the recorded pass callbacks run in a valid order.

Because the whole frame is known before anything is recorded, the graph can make global decisions that a pass cannot make locally.

## What the graph buys you

- **Barrier and layout inference.** Each pass states how it uses a resource (sampled, color target, storage write, and so on). The graph derives the transitions between passes, so no pass needs to know what ran before it.
- **Pass culling.** Passes whose outputs are never read, directly or transitively, by something that reaches the backbuffer or another side effect are removed.
- **Transient resource aliasing.** Resources whose lifetimes do not overlap can share memory. Lifetimes come straight from the first and last pass that touches each resource.
- **Scheduling.** Independent passes can be reordered, or moved to an async compute queue, without changing the renderer code.

## Keeping it cheap

A graph that costs more CPU time than it saves is not worth having. A few things that matter:

- **Rebuild every frame, but without allocating.** Use a per-frame linear allocator for pass and resource descriptions, and reset it at the end of the frame.
- **Keep declaration data small and flat.** Pass nodes with arrays of resource handles, not pointer-linked graphs. Compilation then walks contiguous memory.
- **Use handles, not pointers.** A resource handle is an index plus a generation. Virtual resources get a handle at declaration time; a physical resource is bound only at compile time.
- **Cache physical resources across frames.** Pool transient textures and buffers by description, so aliasing and creation costs are paid once, not every frame.
- **Do the analysis in one or two linear passes.** Culling is a reverse walk from the outputs. Lifetimes and barriers are a forward walk over the final order.

## Where it gets practical

- **Declare usage precisely.** Over-broad usage flags force extra transitions and defeat aliasing. A pass should say exactly which subresource and which stages it touches.
- **Make imports and exports explicit.** Resources that outlive the frame, like the swapchain image or history buffers for temporal effects, must be marked as external so culling and aliasing leave them alone.
- **Keep passes ignorant of each other.** If a pass needs to know what ran before it, the graph is missing information, and that information should be a declared dependency instead.
- **Make the compiled graph inspectable.** A debug dump of pass order, resource lifetimes, and inserted barriers is how you find wasted work. Without one, you are guessing.

## Pitfalls

- **Dynamic content.** Passes that depend on GPU results, such as indirect dispatch counts, cannot be fully resolved at compile time. Declare the worst-case resources and let the pass use less.
- **Async compute is not free.** Cross-queue sync adds latency, and overlapping passes can compete for the same GPU resources. Make it opt-in per pass, and measure.
- **Over-abstraction.** If every small operation becomes a pass, the compile cost grows with no benefit. Group tightly coupled work into one pass.

## Takeaway

A rendergraph is worth it when the information it collects, which is who reads and writes what, is turned into automatic barriers, culling, and memory reuse, and when the per-frame cost of collecting it is close to zero.
