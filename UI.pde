public class TouchRect
{
	int x, y, w, h;
	Runnable onClick, onRelease;
	public TouchRect(int x, int y, int w, int h, Runnable onClick, Runnable onRelease)
	{
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
		this.onClick = onClick;
		this.onRelease = onRelease;
	}

	public boolean touches(int mx, int my)
	{
		return mx >= this.x && mx < this.x + this.w && my >= this.y && my < this.y + this.h;
	}

	public void click()
	{
		this.onClick.run();
	}

	public void release()
	{
		this.onRelease.run();
	}
}

TouchRect getTouchingRect()
{
	ListIterator<TouchRect> it = clickZones.listIterator(clickZones.size());
	while(it.hasPrevious())
	{
		TouchRect rect = it.previous();
		if (rect.touches(mouseX, mouseY))
			return rect;
	}
	return null;
}
