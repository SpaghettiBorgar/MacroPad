public class UIElement
{
	int x, y, w, h;
	Runnable onDraw, onClick, onRelease, onScroll;
	public UIElement(int x, int y, int w, int h, Runnable onDraw, Runnable onClick, Runnable onRelease, Runnable onScroll)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.onDraw = onDraw;
		this.onClick = onClick;
		this.onRelease = onRelease;
		this.onScroll = onScroll;
	}

	public boolean touches(int mx, int my)
	{
		return mx >= this.x && mx < this.x + this.w && my >= this.y && my < this.y + this.h;
	}

	public void draw()
	{
		this.onDraw.run();
	}

	public void click()
	{
		this.onClick.run();
	}

	public void release()
	{
		this.onRelease.run();
	}

	public void scroll()
	{
		this.onScroll.run();
	}
}

public class UI
{
	LinkedList<UIElement> elements;

	public UI()
	{
		elements = new LinkedList<UIElement>();
	}

	public void draw()
	{
		for(UIElement e : elements)
		{
			e.draw();
		}
	}

	public void addElement(UIElement e)
	{
		elements.add(e);
	}

	public void click(int x, int y, int button)
	{
		UIElement e = getTouchingElement(x, y);
		if(e != null)
			e.click();
	}

	public void release(int x, int y, int button)
	{
		UIElement e = getTouchingElement(x, y);
		if(e != null)
			e.release();
	}

	public void scroll(int x, int y, int scroll)
	{
		UIElement e = getTouchingElement(x, y);
		if(e != null)
			e.scroll();
	}

	public UIElement getTouchingElement(int x, int y)
	{
		ListIterator<UIElement> it = elements.listIterator(elements.size());
		while(it.hasPrevious())
		{
			UIElement e = it.previous();
			if (e.touches(x, y))
				return e;
		}
		return null;
	}
}
