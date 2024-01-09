package org.escafe.graph.component
{
	import mx.containers.Canvas;
	import mx.states.SetStyle;
	import mx.events.ResizeEvent;
	import org.escafe.graph.element.Edge;
	import org.escafe.graph.element.Node;
	import mx.events.MoveEvent;
	import org.escafe.graph.element.Element;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import mx.core.ScrollPolicy;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import org.escafe.graph.bitmap.BitmapUtil;
	import flash.events.MouseEvent;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import org.escafe.graph.drag.AbstractDragStrategy;
	import org.escafe.graph.drag.ScrollStrategy;
	import org.escafe.graph.drag.SelectStrategy;
	import mx.collections.ArrayCollection;
	import org.escafe.graph.drag.SelectCircleStrategy;
	import org.escafe.graph.drag.AlignSpaceStrategy;
	import org.escafe.graph.drag.SelectRectangleStrategy;
	import org.escafe.graph.drag.AlignRotateStrategy;

public class GraphEditor extends Graph
{
	private var _lastMouseDownTime: int = 0;
	private var _lastMouseDownSelectedElements: Array = new Array();
	private var _dragStrategy: AbstractDragStrategy;

	/**
	 * @category initialize
	 */
	public function GraphEditor(): void {
		super();
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownOrDoubleClick);
		addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
		addEventListener(MouseEvent.MOUSE_UP, mouseUp);
	}
	
	/**
	 * @category mouse dragger accessing
	 */
	protected function get dragStrategy(): AbstractDragStrategy {
		return _dragStrategy;
	}
	
	/**
	 * @category mouse dragger accessing
	 */
	protected function set dragStrategy(newStrategy: AbstractDragStrategy): void {
		_dragStrategy = newStrategy;
	}
	
	/**
	 * @category mouse accessing
	 */
	private function mouseDownOrDoubleClick(event: MouseEvent): void {
		if (isDoubleClick()) {
			mouseDoubleClick(event);
		} else {
			mouseDown(event);
		}
	}

	/**
	 * @category mouse accessing
	 */
	private function isDoubleClick(): Boolean {
	   	var now: int = flash.utils.getTimer();
	   	var point: Point = getMousePoint();
	   	if ((now - _lastMouseDownTime) < 300) {
			_lastMouseDownTime = 0;
			setSelectedElements(_lastMouseDownSelectedElements);
			_lastMouseDownSelectedElements = new Array();
	   	} else {
			_lastMouseDownTime = now;
			_lastMouseDownSelectedElements = getSelectedElements();
	   	}
	   	return (_lastMouseDownTime == 0);
	}

	/**
	 * @category mouse accessing
	 */
	protected function mouseDoubleClick(event: MouseEvent): void {
		if (event.ctrlKey) {
			_dragStrategy = new AlignRotateStrategy(this);
		} else if (event.shiftKey) {
			_dragStrategy = new AlignSpaceStrategy(this);
		} else {
			_dragStrategy = new ScrollStrategy(this);
		}
		_dragStrategy.mouseDown(getMousePoint());
	}

	/**
	 * @category mouse accessing
	 */
	protected function mouseDown(event: MouseEvent): void {
		if (event.ctrlKey) {
			_dragStrategy = new SelectCircleStrategy(this);
		} else if (event.shiftKey) {
			_dragStrategy = new SelectRectangleStrategy(this);
		} else {
			_dragStrategy = new SelectStrategy(this);
		}
		_dragStrategy.mouseDown(getMousePoint());
	}
	
	/**
	 * @category mouse accessing
	 */
	protected function mouseMove(event: MouseEvent): void {
		if (_dragStrategy != null) {
			if (event.buttonDown) {
				_dragStrategy.mouseDrag(getMousePoint());
			} else {
				mouseUp(event);
			}
		}
	}
	
	/**
	 * @category mouse accessing
	 */
	protected function mouseUp(event: MouseEvent): void {
		if (_dragStrategy != null) {
			_dragStrategy.mouseUp(getMousePoint());
		}
		_dragStrategy = null;
	}

	/**
	 * @category selection accsessing
	 */
	public function getSelectedElements(): Array {
		var elements: ArrayCollection = new ArrayCollection;
		for each (var node: Node in nodeStage.getChildren()) {
			if (node.selected) {
				elements.addItem(node);
			}
		}
		for each (var edge: Edge in edgeStage.getChildren()) {
			if (edge.selected) {
				elements.addItem(edge);
			}
		}
		return elements.toArray();
	}
	
	/**
	 * @category selection accsessing
	 */
	public function setSelectedElements(elements: Array): void {
		for each (var element: Element in elements) {
			element.selected = true;
		}
	}
	
	/**
	 * @category selection accsessing
	 */
	public function selectAllElements(): void {
		for each (var node: Node in nodeStage.getChildren()) {
			node.selected = true;
		}
	}

	/**
	 * @category selection accsessing
	 */
	public function setSelectOneElementAndMoveUp(element: Element): void {
		clearSelectedElements();
		element.selected = true;

		if (element is Node) {
			nodeStage.setChildIndex(element, nodeStage.numChildren - 1);
		} else if (element is Edge) {
			edgeStage.setChildIndex(element, edgeStage.numChildren - 1);
		}
	}
	
	/**
	 * @category selection accsessing
	 */
	public function clearSelectedElements(): void {
		for each (var node: Node in nodeStage.getChildren()) {
			node.selected = false;
		}
		for each (var edge: Edge in edgeStage.getChildren()) {
			edge.selected = false;
		}
	}
	
	/**
	 * @category selection accsessing
	 */
	public function removeSelectedElement(): void {
		for each (var edge: Edge in edgeStage.getChildren().reverse()) {
			if (edge.selected) {
				removeEdge(edge);
			}
		}
		for each (var node: Node in nodeStage.getChildren().reverse()) {
			if (node.selected) {
				removeNode(node);
			}
		}
	}

	/**
	 * @category scroll canvas accessing
	 */
	public function getScrollCanvas(): Canvas {
		return parent as Canvas;
	}
	
	/**
	 * @category scroll canvas accessing
	 */
	public function getMousePoint(): Point {
		return new Point(this.mouseX + this.horizontalScrollPosition, this.mouseY + this.verticalScrollPosition);
	}
}
}