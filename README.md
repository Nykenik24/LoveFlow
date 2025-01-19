# LoveFlow
LoveFlow is an Event-Driven Architecture (EDA) implementation inside Love2d. LoveFlow allows for flexible customization of a message bus, controllable event handlers, publisher-subscriber systems and more.

# Installation
To install LoveFlow, follow this steps:

1. Clone or add as a submodule:
```bash
git clone https://github.com/Nykenik24/LoveFlow.git path/to/loveflow
# or
git submodule add https://github.com/Nykenik24/LoveFlow.git path/to/loveflow
```
2. Require loveflow
```lua
local loveflow = require("path.to.loveflow")
```

# Usage
After installing LoveFlow, you need to **create an architecture**:
```lua
local loveflow = require("loveflow")
local arch = loveflow.newArch()
```
Then create your publishers and subscribers
```lua
--...
local pub = arch.bus:newPublisher()
local sub = arch.bus:newSubscriber()
```
And finally update your architecture in `love.update`
```lua
function love.update(dt)
	arch:updateAll()
end	
```

Now you can publish events:
```lua
pub:publish("Hello, World!")
pub:publish({msg = "Hello, World!", some_var = 5})
```
Subscribe to publishers:
```lua
sub:subscribe(pub)
-- or
sub:subscribe(pub.id)
```
And handle events manually or with `subscriber:handleEvents`:
```lua
sub:handleEvents(arch.bus, function(self, event)
	--...
end)
-- or manually
local sub_events = sub:getEvents()
for id, event in pairs(sub_events) do
	--...
end	
```
You can also broadcast events through `bus:broadcast`
```lua
arch.bus:broadcast("DOOM!? Here in New York!?")
print(sub:getLastBroadcast(arch.bus))
```
## Components
Components in LoveFlow are:
- Publishers.
- Subscribers.
- Event buses.
- Listeners.

This section explains each one of them:
### Event bus *(or event broker)*
---
- Handles the event pool.
- Can broadcast events to all subscribers.
### Publisher
---
- Sends events. 
- Subscribers can suscribe to them to receive all published events.
### Subscriber
---
- Receives events.
- Can subscribe to publishers.
- Can get broadcasts.
### Listener
---
- Listens to events in an event bus.

![EDA Example](images/EDA_example.png)
<details>
<summary>Code</summary>

```lua
local loveflow = require("loveflow")
local arch = loveflow.newArch()

-- ## Create all comps ## --
-- publishers --
local pub_a = arch.bus:newPublisher()
local pub_b = arch.bus:newPublisher()

-- subscribers --
local sub_a = arch.bus:newSubscriber():subscribe(pub_a)
local sub_b = arch.bus:newSubscriber():subscribe(pub_b)
local sub_c = arch.bus:newSubscriber():subscribe(pub_a):subscribe(pub_b)

-- listener --
local listener = arch.bus:newListener()

-- ## Publish and broadcast ## --
pub_a:publish("Event A")
pub_b:publish("Event B")
arch.bus:broadcast("broadcast")
```
</details>

# Recomended usage
LoveFlow is made to be as customizable and flexible as possible, handlers and events are completely custom.

But, there is a recommended workflow i suggest you to follow if you want good event handling.


## `event.type`
You can add a variable called `type` to your events for subscribers to know what to do for every type of event.
```lua
-- enemy.flow is the publisher
-- player.flow is the subscriber

enemy.flow:publish({
	type = "attackPlayer",
	dmg = enemy.dmg, -- damage
	in_range = enemy:inAttackRange(player)
})

player.flow:handleEvents(bus, function(_, event)
	if event.type == "attackPlayer" then
		if event.in_range then 
			player:takeDamage(event.dmg) 
		end	
	elseif event.type == "onDeath" then
		player:respawnOnLastCheckpoint()
	end
end)
```
**Note**: I recommend having some function that handles all the event types instead of a chain of `if` and `elseif`.

## Always make events tables
Tables are the way to go when making your events, they allow for easy storage of all the information you need, a type variable, etc.

If you used strings, then using an event bus instead of a message bus would be dumb. If you used numbers then... What would you really be able to do? If you used booleans then you would have less possibilites than with numbers. 

Functions aren't possible to use because the library discards functions when getting and handling events to avoid passing `last` or any other internal method. If you want to use functions, you could store them in a table and use them like `event[1](...)` or `event.func(...)`.

## Use broadcasts only when necessary
Broadcasts are really useful when you need all subscribers to do something, like a `quit` event that makes all subscribers save their state in the save file before the game is closed.

But if you need a group of subscribers to respond to one source of events, just subscribe them to that source. You can make a publisher have multiple subscribers and viceversa. 

Broadcasts go to all subscribers so you could break something if not careful when using them.

## Use publisher and subscriber alias if you need them
When calling `newSubscriber` and `newPublisher` there is an optional argument: `alias`. Alias is a string that allows you to find a subscriber/publisher inside the bus without having to know the ID.

To find a publisher/subscriber by alias, use the bus methods `findPublisherByAlias` and `findSubscriberByAlias`, this methods will return the publisher/subscriber and their id (publisher) or index (subscriber).

If you use alias, make them as short and understandable as possible. If your publisher takes as a source the player inputs, you can use the alias `Input handler`, `Input publisher` or just `Input`. 

## Use listeners instead of subscribers when needed
If you need something that takes all events, but don't want to create a new subscriber or use one that isn't really related or important, use *listeners*.

Listeners take all events from all sources of an event bus and handles them with the function you provide. 

These are useful when you want something that takes all events sent and have too many publishers to make a subscriber that's takes events from every publisher.

# More about EDA
## What is EDA?
*[src: Geeks For Geeks article on EDA](https://www.geeksforgeeks.org/event-driven-architecture-system-design/)*

With event-driven architecture (EDA), various system components communicate with one another by generating, identifying, and reacting to events. These events can be important happenings, like user actions or changes in the system's state. In EDA, components are independent, meaning they can function without being tightly linked to one another. When an event takes place, a message is dispatched, prompting the relevant components to respond accordingly. This structure enhances flexibility, scalability, and real-time responsiveness in systems.


## Why is EDA useful?
Event-driven architecture inside your game allows for a very flexible game event system, allowing for modularity and control of internal game events.

LoveFlow implements a simple EDA system that allows to quickly setup publishers, subscribers, event handlers, etc. in a fast and easy manner.




