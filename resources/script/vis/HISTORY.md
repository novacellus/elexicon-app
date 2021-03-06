# vis.js history
http://visjs.org


## 2014-08-29, version 3.3.0

### Timeline

- Added localization support.
- Implemented option `clickToUse`.
- Implemented function `focus(id)` to center a specific item (or multiple items)
  on screen.
- Implemented an option `focus` for `setSelection(ids, options)`, to immediately
  focus selected nodes.
- Implemented function `moveTo(time, options)`.
- Implemented animated range change for functions `fit`, `focus`, `setSelection`,
  and `setWindow`.
- Implemented functions `setCurrentTime(date)` and `getCurrentTime()`.
- Implemented a new callback function `onMoving(item, callback)`.
- Implemented support for option `align` for range items.
- Fixed the `change` event sometimes being fired twice on IE10.
- Fixed canceling moving an item to another group did not move the item
  back to the original group.
- Fixed the `change` event sometimes being fired twice on IE10.
- Fixed canceling moving an item to another group did not move the item
  back to the original group.

### Network

- A fix in reading group properties for a node.
- Fixed physics solving stopping when a support node was not moving.
- Implemented localization support.
- Implemented option `clickToUse`.
- Improved the `'stabilized'` event, it's now firing after every stabilization
  with iteration count as parameter.
- Fixed page scroll event not being blocked when moving around in Network
  using arrow keys.
- Fixed an initial rendering before the graph has been stabilized.
- Fixed bug where loading hierarchical data after initialization crashed network.
- Added different layout method to the hierarchical system based on the direction of the edges.

### Graph2D

- Implemented option `handleOverlap` to support overlap, sideBySide and stack.
- Implemented two examples showing the `handleOverlap` functionality.
- Implemented `customRange` for the Y axis and an example showing how it works.
- Implemented localization support.
- Implemented option `clickToUse`.
- Implemented functions `setCurrentTime(date)` and `getCurrentTime()`.
- Implemented function `moveTo(time, options)`.
- Fixed bugs.
- Added groups.visibility functionality and an example showing how it works.


## 2014-08-14, version 3.2.0

### General

- Refactored Timeline and Graph2d to use the same core.

### Graph2D

- Added `visible` property to the groups.
- Added `getLegend()` method.
- Added `isGroupVisible()` method.
- Fixed empty group bug.
- Added `fit()` and `getItemRange()` methods.

### Timeline

- Fixed items in groups sometimes being displayed but not positioned correctly.
- Fixed a group "null" being displayed in IE when not using groups.

### Network

- Fixed mass = 0 for nodes.
- Revamped the options system. You can globally set options (network.setOptions) to update settings of nodes and edges that have not been specifically defined by the individual nodes and edges.
- Disabled inheritColor when color information is set on an edge.
- Tweaked examples.
- Removed the global length property for edges. The edgelength is part of the physics system. Therefore, you have to change the springLength of the physics system to change the edge length. Individual edge lengths can still be defined.
- Removed global edge length definition form examples.
- Removed onclick and onrelease for navigation and switched to Hammer.js (fixing touchscreen interaction with navigation).
- Fixed error on adding an edge without having created the nodes it should be connected to (in the case of dynamic smooth curves).


## 2014-07-22, version 3.1.0

### General

- Refactored the code to commonjs modules, which are browserifyable. This allows
  to create custom builds.

### Timeline

- Implemented function `getVisibleItems()`, which returns the items visible
  in the current window.
- Added options `margin.item.horizontal` and  `margin.item.vertical`, which
  allows to specify different margins horizontally/vertically.
- Removed check for number of arguments in callbacks `onAdd`, `onUpdate`, 
  `onRemove`, and `onMove`.
- Fixed items in groups sometimes being displayed but not positioned correctly.
- Fixed range where the `end` of the first is equal to the `start` of the second 
  sometimes being stacked instead of put besides each other when `item.margin=0`
  due to round-off errors.

### Network (formerly named Graph)

- Expanded smoothCurves options for improved support for large clusters.
- Added multiple types of smoothCurve drawing for greatly improved performance.
- Option for inherited edge colors from connected nodes.
- Option to disable the drawing of nodes or edges on drag.
- Fixed support nodes not being cleaned up if edges are removed.
- Improved edge selection detection for long smooth curves.
- Fixed dot radius bug.
- Updated max velocity of nodes to three times it's original value.
- Made "stabilized" event fire every time the network stabilizes.
- Fixed drift in dragging nodes while zooming.
- Fixed recursively constructing of hierarchical layouts.
- Added borderWidth option for nodes.
- Implemented new Hierarchical view solver.
- Fixed an issue with selecting nodes when the web page is scrolled down.
- Added Gephi JSON parser
- Added Neighbour Highlight example
- Added Import From Gephi example
- Enabled color parsing for nodes when supplied with rgb(xxx,xxx,xxx) value.

### DataSet

- Added .get() returnType option to return as JSON object, Array or Google 
  DataTable.



## 2014-07-07, version 3.0.0

### Timeline

- Implemented support for displaying a `title` for both items and groups.
- Fixed auto detected item type being preferred over the global item `type`.
- Throws an error when constructing without new keyword.
- Removed the 'rangeoverflow' item type. Instead, one can use a regular range
  and change css styling of the item contents to:

        .vis.timeline .item.range .content {
          overflow: visible;
        }
- Fixed the height of background and foreground panels of groups.
- Fixed ranges in the Timeline sometimes overlapping when dragging the Timeline.
- Fixed `DataView` not working in Timeline.

### Network (formerly named Graph)

- Renamed `Graph` to `Network` to prevent confusion with the visualizations 
  `Graph2d` and `Graph3d`.
  - Renamed option `dragGraph` to `dragNetwork`.
- Now throws an error when constructing without new keyword.
- Added pull request from Vukk, user can now define the edge width multiplier 
  when selected.
- Fixed `graph.storePositions()`.
- Extended Selection API with `selectNodes` and `selectEdges`, deprecating 
  `setSelection`.
- Fixed multiline labels.
- Changed hierarchical physics solver and updated docs.

### Graph2d

- Added first iteration of the Graph2d.

### Graph3d

- Now throws an error when constructing without new keyword.


## 2014-06-19, version 2.0.0

### Timeline

- Implemented function `destroy` to neatly cleanup a Timeline.
- Implemented support for dragging the timeline contents vertically.
- Implemented options `zoomable` and `moveable`.
- Changed default value of option `showCurrentTime` to true.
- Internal refactoring and simplification of the code.
- Fixed property `className` of groups not being applied to related contents and 
  background elements, and not being updated once applied.

### Graph

- Reduced the timestep a little for smoother animations.
- Fixed dataManipulation.initiallyVisible functionality (thanks theGrue).
- Forced typecast of fontSize to Number.
- Added editing of edges using the data manipulation toolkit.

### DataSet

- Renamed option `convert` to `type`.


## 2014-06-06, version 1.1.0

### Timeline

- Select event now triggers repeatedly when selecting an already selected item.
- Renamed `Timeline.repaint()` to `Timeline.redraw()` to be consistent with
  the other visualisations of vis.js.
- Fixed `Timeline.clear()` not resetting a configured `options.start` and 
  `options.end`.

### Graph

- Fixed error with zero nodes with hierarchical layout.
- Added focusOnNode function.
- Added hover option.
- Added dragNodes option. Renamed movebale to dragGraph option.
- Added hover events (hoverNode, blurNode).

### Graph3D

- Ported Graph3D from Chap Links Library.


## 2014-05-28, version 1.0.2

### Timeline

- Implemented option `minHeight`, similar to option `maxHeight`.
- Implemented a method `clear([what])`, to clear items, groups, and configuration
  of a Timeline instance.
- Added function `repaint()` to force a repaint of the Timeline.
- Some tweaks in snapping dragged items to nice dates.
- Made the instance of moment.js packaged with vis.js accessibly via `vis.moment`.
- A newly created item is initialized with `end` property when option `type`
  is `"range"` or `"rangeoverflow"`.
- Fixed a bug in replacing the DataSet of groups via `Timeline.setGroups(groups)`.
- Fixed a bug when rendering the Timeline inside a hidden container. 
- Fixed axis scale being determined wrongly for a second Timeline in a single page.

### Graph

- Added zoomable and moveable options.
- Changes setOptions to avoid resetting view.
- Interchanged canvasToDOM and DOMtoCanvas to correspond with the docs.


## 2014-05-09, version 1.0.1

### Timeline

- Fixed width of items with type `rangeoverflow`.
- Fixed a bug wrongly rendering invisible items after updating them.

### Graph

- Added coordinate conversion from DOM to Canvas.
- Fixed bug where the graph stopped animation after settling in playing with physics.
- Fixed bug where hierarchical physics properties were not handled.
- Added events for change of view and zooming.


## 2014-05-02, version 1.0.0

### Timeline

- Large refactoring of the Timeline, simplifying the code.
- Great performance improvements.
- Improved layout of box-items inside groups.
- Items can now be dragged from one group to another.
- Implemented option `stack` to enable/disable stacking of items.
- Implemented function `fit`, which sets the Timeline window such that it fits
  all items.
- Option `editable` can now be used to enable/disable individual manipulation
  actions (`add`, `updateTime`, `updateGroup`, `remove`).
- Function `setWindow` now accepts an object with properties `start` and `end`.
- Fixed option `autoResize` forcing a repaint of the Timeline with every check
  rather than when the Timeline is actually resized.
- Fixed `select` event fired repeatedly when clicking an empty place on the
  Timeline, deselecting selected items).
- Fixed initial visible window in case items exceed `zoomMax`. Thanks @Remper.
- Fixed an offset in newly created items when using groups.
- Fixed height of a group not reckoning with the height of the group label.
- Option `order` is now deprecated. This was needed for performance improvements.
- More examples added.
- Minor bug fixes.

### Graph

- Added recalculate hierarchical layout to update node event.
- Added arrowScaleFactor to scale the arrows on the edges.

### DataSet

- A DataSet can now be constructed with initial data, like
  `new DataSet(data, options)`.


## 2014-04-18, version 0.7.4

### Graph

- Fixed IE9 bug.
- Style fixes.
- Minor bug fixes.


## 2014-04-16, version 0.7.3

### Graph

- Fixed color bug.
- Added pull requests from kannonboy and vierja: tooltip styling, label fill 
  color.


## 2014-04-09, version 0.7.2

### Graph

- Fixed edge select bug.
- Fixed zoom bug on empty initialization.


## 2014-03-27, version 0.7.1

### Graph

- Fixed edge color bug.
- Fixed select event bug.
- Clarified docs, stressing importance of css inclusion for correct display of 
  navigation an manipulation icons.
- Improved and expanded playing with physics (configurePhysics option).
- Added highlights to navigation icons if the corresponding key is pressed.
- Added freezeForStabilization option to improve stabilization with cached 
  positions.


## 2014-03-07, version 0.7.0

### Graph

- Changed navigation CSS. Icons are now always correctly positioned.
- Added stabilizationIterations option to graph.
- Added storePosition() method to save the XY positions of nodes in the DataSet.
- Separated allowedToMove into allowedToMoveX and allowedToMoveY. This is 
  required for initializing nodes from hierarchical layouts after 
  storePosition().
- Added color options for the edges.


## 2014-03-06, version 0.6.1

### Graph

- Bugfix graphviz examples.
- Bugfix labels position for smooth curves.
- Tweaked graphviz example physics.
- Updated physics documentation to stress importance of configurePhysics.

### Timeline

- Fixed a bug with options `margin.axis` and `margin.item` being ignored when 
  setting them to zero.
- Some clarifications in the documentation.


## 2014-03-05, version 0.6.0

### Graph

- Added Physics Configuration option. This makes tweaking the physics system to 
  suit your needs easier.
- Click and doubleClick events.
- Initial zoom bugfix.
- Directions for Hierarchical layout.
- Refactoring and bugfixes.


## 2014-02-20, version 0.5.1

- Fixed broken bower module.


## 2014-02-20, version 0.5.0

### Timeline

- Editable Items: drag items, add new items, update items, and remove items.
- Implemented options `selectable`, `editable`.
- Added events `timechange` and `timechanged` when dragging the custom time bar.
- Multiple items can be selected using ctrl+click or shift+click.
- Implemented functions `setWindow(start, end)` and `getWindow()`.
- Fixed scroll to zoom not working on IE in standards mode.

### Graph

- Editable nodes and edges: create, update, and remove them.
- Support for smooth, curved edges (on by default).
- Performance improvements.
- Fixed scroll to zoom not working on IE in standards mode.
- Added hierarchical layout option.
- Overhauled physics system, now using Barnes-Hut simulation by default. Great 
  performance gains.
- Modified clustering system to give better results.
- Adaptive performance system to increase visual performance (60fps target).

### DataSet

- Renamed functions `subscribe` and `unsubscribe` to `on` and `off` respectively.


## 2014-01-31, version 0.4.0

### Timeline

- Implemented functions `on` and `off` to create event listeners for events
  `rangechange`, `rangechanged`, and `select`.
- Implemented function `select` to get and set the selected items.
- Items can be selected by clicking them, muti-select by holding them.
- Fixed non working `start` and `end` options.

### Graph

- Fixed longstanding bug in the force calculation, increasing simulation
  stability and fluidity.
- Reworked the calculation of the Graph, increasing performance for larger
  datasets (up to 10x!).
- Support for automatic clustering in Graph to handle large (>50000) datasets
  without losing performance.
- Added automatic initial zooming to Graph, to more easily view large amounts
  of data.
- Added local declustering to Graph, freezing the simulation of nodes outside
  of the cluster.
- Added support for key-bindings by including mouseTrap in Graph.
- Added navigation controls.
- Added keyboard navigation.
- Implemented functions `on` and `off` to create event listeners for event
  `select`.


## 2014-01-14, version 0.3.0

- Moved the generated library to folder `./dist`
- Css stylesheet must be loaded explicitly now.
- Implemented options `showCurrentTime` and `showCustomTime`. Thanks @fi0dor.
- Implemented touch support for Timeline.
- Fixed broken Timeline options `min` and `max`.
- Fixed not being able to load vis.js in node.js.


## 2013-09-20, version 0.2.0

- Implemented full touch support for Graph.
- Fixed initial empty range in the Timeline in case of a single item.
- Fixed field `className` not working for items.


## 2013-06-20, version 0.1.0

- Added support for DataSet to Graph. Graph now uses an id based set of nodes
  and edges instead of a row based array internally. Methods getSelection and
  setSelection of Graph now accept a list with ids instead of rows.
- Graph is now robust against edges pointing to non-existing nodes, which
  can occur easily while dynamically adding/removing nodes and edges.
- Implemented basic support for groups in the Timeline.
- Added documentation on DataSet and DataView.
- Fixed selection of nodes in a Graph when the containing web page is scrolled.
- Improved date conversion.
- Renamed DataSet option `fieldTypes` to `convert`.
- Renamed function `vis.util.cast` to `vis.util.convert`.


## 2013-06-07, version 0.0.9

- First working version of the Graph imported from the old library.
- Documentation added for both Timeline and Graph.


## 2013-05-03, version 0.0.8

- Performance improvements: only visible items are rendered.
- Minor bug fixes and improvements.


## 2013-04-25, version 0.0.7

- Sanitized the published packages on npm and bower.


## 2013-04-25, version 0.0.6

- Css is now packaged in the javascript file, and automatically loaded.
- The library uses node style dependency management for modules now, used
  with Browserify.


## 2013-04-16, version 0.0.5

- First working version of the Timeline.
- Website created.
