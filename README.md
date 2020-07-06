# line-graph-vis

Linear line graph visualization using Processing 3.

![Preview of line-graph-vis](lv-preview.gif "Preview of line-graph-vis(-static)")

There are two types which are full and static. Each with a GraphSystem and line_graph_vis. For full, the data is shown entirely from start to current time/finish. For static (still expreimental!), the data "scrolls" through time.

## Instructions
1. Open both GraphSystem(_Static).pde and line_graph_vis(_static).pde in a seperate sketch folder.
2. Make sure the data file is in the folder or use your data.
3. Experiments with the input numbers! If you have any question please raise it in the issues tab.

### Movement in Static Mode
In static mode where vertical axis try to fit the line graph, the code supports auto playbacking (not 100% reliable), normal playback, recording and playbacking from the recorded movement.

* When you press the UP arrow key, the screen move "up" (as the y value increases). When you press it again, it will stop moving up. This is the same for DOWN arrow key.
* When you press the 'w' key, the screen will "zoom in" (as the y scale decreases). When you press it again, it will stop zooming in. This is the same for 's' key where it will zoom out.
* NOTE: Zooming in/out will causes slight vertical movement. You can compensate it by pressing both 's' and DOWN key at the same time.

## TODO

### Full
* Add axes names.
* Have the text not stack with one another.
* Loading color from external file for convenience.
* Simplify code.

### Static
* Add axes names.
* Implement coloring of lines and text.
* Dot pulse when data becomes either avaliable or not available.
* Have the text not stack with one another.
* Improved zooming system.
* Simplify code...?

## License
This source code is distributed under GNU General Public License v3.0. If you create an image or/and a video using the software and upload, broadcast or share with any other means, you must credit the software used and include a link to this GitHub repository.
