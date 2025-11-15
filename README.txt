For Paracortical Initiative, 2025, Diogo "Theklo" Duarte

Other projects:
https://bsky.app/profile/diogo-duarte.bsky.social
https://diogo-duarte.itch.io/
https://github.com/Theklo-Teal


# DESCRIPTION
A sort of circuit simulator for digital logic that's intuitive to use, made in the Godot Engine. I intended to use it to test my ideas on signal propagation and have novel components that more realistic simulators don't have.
This is part of my collection of projects in indefinite hiatus. I release it publicly in case someone likes the ideas and wants to develop them further or volunteers to work with me on them.
See "WHY IN HIATUS?" for more information.

# THE CONCEPT
The basic component is a electromechanical relay. It's easy to understand its function and with variable amounts of switches and poles complex things can be accomplished while still be comprehensible.
Current and voltage aren't really accounted in this simulator, but voltmeters and ammeters would be devices that count the devices connected in parallel, series and display their logic state in a single panel.
One thing that bothers me about Logisim, is the lack of dual port RAM which I'm interested to use in my CPU architecture designs. So I was hopeful that my simulator could be used to design my CPU ideas and test their features.
I was also curious if there would be interest from other people in a simulator that deals with odd logic devices like Minecraft's Redstone logic. Although Minecraft doesn't do anything impossible with real electronics, it reduces relatively complicated systems (eg. signal delay and comparators) into single components instead of letting you build from lower level devices. It requires a different kind of thinking and that can have educational value.
This project could be thought as the toy logic sim from Sebastian Lague, but on steroids. Some of the design decisions were inspired by the game Turing Complete, which was also made in Godot. But I feel that simulator is purposefully restrictive. Some ideas might also be taken from Falstad's Circuit Sim, at later stage of development.

# INSTALLATION
Put these files in your Godot projects folder and search for it in project manager of Godot! Compatible with Godot 4.5.

# USAGE
Note: several of these usage instructions pertain to features that haven't been implemented.
The work area is an infinite panning canvas ("Flowcharter" class). Components are added from a tray and you can also add notes as boxes with no function, but display text and can point to components.
When selecting a component you can change its parameters in the bottom tray, and even tell to display its control inputs (eg. switches) and indicator outputs (eg. number displays) on the left and right sidebars, if available. This way you can build a console to control a project device without searching around the canvas for components
Middle mouse button pans the work area, left button selects things, including box selection, which has different behaviour if dragged top to bottom or bottom to top.
There are multiple layers to a circuit, much in the same way real circuit boards have different components and wires in different layers. This allows the a project to look more compact and clean.
You may set a different theme (colors and grid pattern) to different layers, making them easily recognizable.
The solenoids and the switches of relays could be displayed in different layers, allowing for a neat separation of logic and actions.
It should be easy to create new components by instancing the "electro_element.tscn" and put in the paramters for slots, then inherit its script with a new one with the behaviour rules desired.
You can create new components by selecting a segment of a circuit and pressing the "isolate" button, which replaces that segment into a subcircuit as a single component.
Circuits can be exported as PNG or PDF drawings that could be printed.

# WHY IN HIATUS?
In an older iteration of this project, the components on the work area were indexed in a dictionary, so spatial hash grid partitioning techniques could be used to render and box-select components effectively.
The current version is a refactoring where I haven't restored that function again.
Now, for starters, there's a method that might be bogus or cumbersome to find coordinates between local space of the work area UI panel and the sub-local space of the infinite canvas, which accounts zooming and panning. This method was found mostly by trial-and-error and it's always confusing about which coordinate system I'm supposed to according to which purpose. Clicking something on the workspace and it appearing the wrong place is not uncommon.
Someone told me there might be a Godot function that handles this for me, but I have no idea if it handles all the custom drawing I'm making and I'm afraid to break a lot of things when trying to experiment different functions I don't understand.
A major roadblock was in how to efficiently represent the connections between components. Each component has slots and wires connect between them. Some slots are intended as input, others as output, but how do I handle bidirectional behaviour, like in buses? They also need ways to define a high impedance state and not only "Hi" and "Lo" boolean. Is the record of these connections stored in a singleton script? Does each component know what it connects to? How do the wires tell the coordinate of the slot where they should draw from?
After solving that, I suspect the simulation itself would be easy to implement. See the "electro_element.gd" for the basic structure of the implementation. Don't forget to account that feedback loops could cause recursive recursion and freeze the program! The simulation should allow for feedback in designs, but don't forget to handle it properly.
Finally another thing that doesn't really block development but bothers me is how to represent the components. It needs to be sleek and compact. It needs to allow a little hover-mouse panel to change the name and pin devices quickly. My idea was to just have a texture panel and let an artist deal with the representations, but a more procedural solution would be cool.
