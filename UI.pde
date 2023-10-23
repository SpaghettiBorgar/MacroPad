public interface UIElement<T extends UIElement<T>> {
	public boolean touches(int x, int y);
	public T onDraw(Runnable onDraw);
	public T onClick(Runnable onClick);
	public T onRelease(Runnable onRelease);
	public T onScroll(Runnable onScroll);
	public void draw();
	public void click();
	public void release();
	public void scroll();
}

public abstract class AbstractUIBasicElement<T extends AbstractUIBasicElement<T>> implements UIElement<T> {
	int x, y, w, h;
	Runnable onDraw, onClick, onRelease, onScroll;

	public AbstractUIBasicElement(int x, int y, int w, int h) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.onDraw = this.onClick = this.onRelease = this.onScroll = () -> {};
	}

	public boolean touches(int mx, int my) {
		return mx >= this.x && mx < this.x + this.w && my >= this.y && my < this.y + this.h;
	}

	public T onDraw(Runnable onDraw) {
		this.onDraw = onDraw;
		return (T) this;
	}

	public T onClick(Runnable onClick) {
		this.onClick = onClick;
		return (T) this;
	}

	public T onRelease(Runnable onRelease) {
		this.onRelease = onRelease;
		return (T) this;
	}

	public T onScroll(Runnable onScroll) {
		this.onScroll = onScroll;
		return (T) this;
	}

	public void draw() {
		this.onDraw.run();
	}

	public void click() {
		this.onClick.run();
	}

	public void release() {
		this.onRelease.run();
	}

	public void scroll() {
		this.onScroll.run();
	}
}

public class UIBasicElement extends AbstractUIBasicElement<UIBasicElement> {
	public UIBasicElement(int x, int y, int w, int h) {
		super(x, y, w, h);
	}
}

public abstract class AbstractUIDropdown<T extends AbstractUIDropdown<T>> extends AbstractUIBasicElement<T> {
	String options[];
	int selectedOption;
	boolean expanded;
	Runnable onSelect;

	public AbstractUIDropdown(int x, int y, int w, int h) {
		super(x, y, w, h);
	}

	public T onSelect(Runnable onSelect) {
		this.onSelect = onSelect;
		return (T) this;
	}
}

public class UIDropdown extends AbstractUIDropdown<UIDropdown> {
	public UIDropdown(int x, int y, int w, int h) {
		super(x, y, w, h);
		this.expanded = false;
	}
}

public class UI {
	LinkedList<UIElement> elements;

	public UI() {
		elements = new LinkedList<UIElement>();
	}

	public void draw() {
		for(UIElement e : elements) {
			e.draw();
		}
	}

	public void addElement(UIElement e) {
		elements.add(e);
	}

	public void click(int x, int y, int button) {
		UIElement e = getTouchingElement(x, y);
		if(e != null)
			e.click();
	}

	public void release(int x, int y, int button) {
		UIElement e = getTouchingElement(x, y);
		if(e != null)
			e.release();
	}

	public void scroll(int x, int y, int scroll) {
		UIElement e = getTouchingElement(x, y);
		if(e != null)
			e.scroll();
	}

	public UIElement getTouchingElement(int x, int y) {
		ListIterator<UIElement> it = elements.listIterator(elements.size());
		while(it.hasPrevious()) {
			UIElement e = it.previous();
			if (e.touches(x, y))
				return e;
		}
		return null;
	}
}
