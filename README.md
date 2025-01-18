# LoveFlow
LoveFlow is an Event-Driven Architecture (EDA) implementation inside Love2d. LoveFlow allows for flexible customization of a message bus, controllable event handlers, publisher-subscriber systems and more.

#### _LoveFlow is currently work in progress, in a alpha state, waiting for more releases/updates is recommended_

## What is EDA?
*[src: Geeks For Geeks article on EDA](https://www.geeksforgeeks.org/event-driven-architecture-system-design/)*

With event-driven architecture (EDA), various system components communicate with one another by generating, identifying, and reacting to events.

<details>
<summary>Full EDA Definition</summary>
With event-driven architecture (EDA), various system components communicate with one another by generating, identifying, and reacting to events. These events can be important happenings, like user actions or changes in the system's state. In EDA, components are independent, meaning they can function without being tightly linked to one another. When an event takes place, a message is dispatched, prompting the relevant components to respond accordingly. This structure enhances flexibility, scalability, and real-time responsiveness in systems.
</details>

## Why is EDA useful?
Event-driven architecture inside your game allows for a very flexible game event system, allowing for modularity and control of internal game events.

LoveFlow implements a simple EDA system that allows to quickly setup publishers, subscribers, event handlers, etc. in a fast and easy manner.



