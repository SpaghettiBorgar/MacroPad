public interface UIElement<T extends UIElement<T>> {
	public boolean touches(int x, int y);
	public T onDraw(Runnable onDraw);
	public T onClick(Runnable onClick);
	public T onRelease(Runnable onRelease);
	public T onScroll(Runnable onScroll);
	public T onKeyUp(Runnable onKeyUp);
	public T onKeyDown(Runnable onKeyDown);
	public T onHover(Runnable onHover);
	public T onLeave(Runnable onLeave);
	public T onFocus(Runnable onFocus);
	public T onUnfocus(Runnable onUnfocus);
	public void draw();
	public void click();
	public void release();
	public void scroll();
	public void keyUp();
	public void keyDown();
	public void hover();
	public void leave();
	public void focus();
	public void unfocus();
	public int x();
	public T x(int v);
	public int y();
	public T y(int v);
	public int w();
	public T w(int v);
	public int h();
	public T h(int v);
	public T xy(int x, int y);
	public T wh(int w, int h);
	public T xywh(int x, int y, int w, int h);
	public T setUI(UI ui);
}

public interface HoldsValue<T, E> {
	public E value();
	public T value(E value);
	public T onChange(Runnable onChange);
}

public abstract class AbstractUIBasicElement<T extends AbstractUIBasicElement<T>> implements UIElement<T> {
	PApplet ctx;
	UI ui;
	int x, y, w, h;
	Runnable onDraw, onClick, onRelease, onScroll, onKeyUp, onKeyDown, onHover, onLeave, onFocus, onUnfocus;

	public AbstractUIBasicElement(PApplet ctx) {
		this.ctx = ctx;
		this.onDraw = this.onClick = this.onRelease = this.onScroll =
		this.onKeyUp = this.onKeyDown = this.onHover = this.onLeave =
		this.onFocus = this.onUnfocus = () -> {};
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

	public T onKeyUp(Runnable onKeyUp) {
		this.onKeyUp = onKeyUp;
		return (T) this;
	}

	public T onKeyDown(Runnable onKeyDown) {
		this.onKeyDown = onKeyDown;
		return (T) this;
	}

	public T onHover(Runnable onHover) {
		this.onHover = onHover;
		return (T) this;
	}

	public T onLeave(Runnable onLeave) {
		this.onLeave = onLeave;
		return (T) this;
	}

	public T onFocus(Runnable onFocus) {
		this.onFocus = onFocus;
		return (T) this;
	}

	public T onUnfocus(Runnable onUnfocus) {
		this.onUnfocus = onUnfocus;
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

	public void keyUp() {
		this.onKeyUp.run();
	}

	public void keyDown() {
		this.onKeyDown.run();
	}

	public void hover() {
		this.onHover.run();
	}

	public void leave() {
		this.onLeave.run();
	}

	public void focus() {
		this.onFocus.run();
	}

	public void unfocus() {
		this.onUnfocus.run();
	}

	public int x() {
		return x;
	}
	public T x(int v) {
		this.x = v;
		return (T) this;
	}
	public int y() {
		return y;
	}
	public T y(int v) {
		this.y = v;
		return (T) this;
	}
	public int w() {
		return w;
	}
	public T w(int v) {
		this.w = v;
		return (T) this;
	}
	public int h() {
		return h;
	}
	public T h(int v) {
		this.h = v;
		return (T) this;
	}
	public T xy(int x, int y) {
		this.x(x);
		this.y(y);
		return (T) this;
	}
	public T wh(int w, int h) {
		this.w(w);
		this.h(h);
		return (T) this;
	}
	public T xywh(int x, int y, int w, int h) {
		this.xy(x, y);
		this.wh(w, h);
		return (T) this;
	}
	public T setUI(UI ui) {
		this.ui = ui;
		return (T) this;
	}
}

public abstract class AbstractUICompositeElement<T extends AbstractUICompositeElement<T>> extends AbstractUIBasicElement<T> {
	ArrayList<UIElement> children;
	UIElement hover;
	UIElement focus;

	public AbstractUICompositeElement(PApplet ctx) {
		super(ctx);
		this.children = new ArrayList<>();
	}

	private UIElement getTouchingChild() {
		ListIterator<UIElement> it = children.listIterator(children.size());
		while(it.hasPrevious()) {
			UIElement c = it.previous();
			if (c.touches(ctx.mouseX, ctx.mouseY))
				return c;
		}
		return null;
	}

	@Override
	public void draw() {
		super.draw();
		for (UIElement child : children)
			child.draw();
	}

	public void click() {
		UIElement e = getTouchingChild();
		focusChild(e);
		if(focus != null)
			focus.click();
		else
			super.click();
	}

	public void release() {
		UIElement e = getTouchingChild();
		if(e != null)
			e.release();
		else
			super.release();
	}

	public void scroll() {
		UIElement e = getTouchingChild();
		if(e != null)
			e.scroll();
		else
			super.scroll();
	}

	public void keyUp() {
		UIElement e = getTouchingChild();
		if(e != null)
			e.keyUp();
		else
			super.keyUp();
	}

	public void keyDown() {
		UIElement e = getTouchingChild();
		if(e != null)
			e.keyDown();
		else
			super.keyDown();
	}

	public void hover() {
		UIElement e = getTouchingChild();
		if(e != null) {
			if(hover != null && hover != e)
				hover.leave();
			hover = e;
			hover.hover();
		} else {
			if(hover != null)
				hover.leave();
			hover = null;
			super.hover();
		}
	}

	public void leave() {
		if(hover != null) {
			hover.leave();
			hover = null;
		}
		super.leave();
	}

	protected void focusChild(UIElement e) {
		if(focus != e)
			unfocusChild();
		focus = e;
		if(focus != null)
			focus.focus();
	}

	protected void unfocusChild() {
		if(focus != null) {
			focus.unfocus();
			focus = null;
		}
	}

	@Override
	public void unfocus() {
		unfocusChild();
		super.unfocus();
	}

	@Override
	public T x(int x) {
		int dx = x - this.x;
		for (UIElement child : children) {
			child.x(child.x() + dx);
		}
		return super.x(x);
	}

	@Override
	public T y(int y) {
		int dy = y - this.y;
		for (UIElement child : children) {
			child.y(child.y() + dy);
		}
		return super.y(y);
	}

	@Override
	public T setUI(UI ui) {
		for (UIElement child : children) {
			child.setUI(ui);
		}
		return super.setUI(ui);
	}

}

public class AbstractUIGroup<T extends AbstractUIGroup<T>> extends AbstractUICompositeElement<T> {
	public AbstractUIGroup(PApplet ctx, UIElement... elements) {
		super(ctx);
		add(elements);
	}

	public T add(UIElement... elements) {
		for(UIElement e : elements) {
			children.add(e);
			if(e.x() < this.x()) {
				this.w(this.w() + (this.x() - e.x()));
				this.x(e.x());
			}
			if(e.y() < this.y()) {
				this.h(this.h() + (this.y() - e.y()));
				this.y(e.y());
			}
			if(e.x() + e.w() > this.x() + this.w()) {
				this.w(this.w() + (e.x() + e.w() - this.x() - this.w()));
			}
			if(e.y() + e.h() > this.y() + this.h()) {
				this.h(this.h() + (e.y() + e.h() - this.y() - this.h()));
			}
		}
		return (T) this;
	}

	@Override
	public T x(int x) {
		this.x = x;
		return (T) this;
	}

	@Override
	public T y(int y) {
		this.y = y;
		return (T) this;
	}
}

public class UIGroup extends AbstractUIGroup<UIGroup> {
	public UIGroup(PApplet ctx, UIElement... elements) {
		super(ctx, elements);
	}

	public void foo() {

	}
}

public class UIBasicElement extends AbstractUIBasicElement<UIBasicElement> {
	public UIBasicElement(PApplet ctx) {
		super(ctx);
	}
}

public abstract class AbstractUIDropdown<T extends AbstractUIDropdown<T, E>, E> extends AbstractUIBasicElement<T> implements HoldsValue<T, E> {
	ArrayList<E> options;
	int selectedOption;
	UIDropdownExpanded expanded;
	boolean hovering;
	Runnable onChange;

	public AbstractUIDropdown(PApplet ctx) {
		super(ctx);
		this.h(24);
		this.options = new ArrayList<>();
		this.expanded = null;
		this.onDraw = () -> {this._onDraw();};
		this.onClick = () -> {this._onClick();};
		this.onScroll = () -> {this._onScroll();};
		this.onKeyDown = () -> {this._onKeyDown();};
		this.onHover = () -> {this._onHover();};
		this.onLeave = () -> {this._onLeave();};
		this.onChange = () -> {};
	}

	private void _onDraw() {
		ctx.fill(200);
		ctx.rect(this.x, this.y, this.w, this.h);
		if(hovering) {
			ctx.fill(0, 0, 0, 20);
			ctx.rect(this.x, this.y, this.w, this.h);
		}
		ctx.fill(40);
		ctx.textAlign(RIGHT, CENTER);
		ctx.text("↓", x, y, w - 2, h);
		ctx.fill(0);
		ctx.textSize(16);
		ctx.textAlign(LEFT, CENTER);
		ctx.text(options.isEmpty() ? "—" : makeString(options.get(selectedOption)), this.x + 4, this.y + this.h / 2);
	}

	private void _onClick() {
		expanded = new UIDropdownExpanded();
		expanded.hovering = selectedOption;
		ui.setPopup(expanded);
	}

	private void _onScroll() {
		changeSelectedOption(ui.scrollY);
	}

	private void _onKeyDown() {
		switch(ctx.keyCode) {
		case UP:
			changeSelectedOption(-1);
			break;
		case DOWN:
			changeSelectedOption(1);
			break;
		case ENTER:
		case RETURN:
			expanded = new UIDropdownExpanded();
			expanded.hovering = selectedOption;
			ui.setPopup(expanded);
		}
	}

	private void _onHover() {
		hovering = true;
	}

	private void _onLeave() {
		hovering = false;
	}

	private void changeSelectedOption(int n) {
		selectedOption = options.isEmpty() ? 0 : clamp(selectedOption + n, 0, options.size() - 1);
		this.onChange.run();
	}

	public T onChange(Runnable onChange) {
		this.onChange = onChange;
		return (T) this;
	}

	public T addOptions(E... options) {
		this.options.addAll(Arrays.asList(options));
		ctx.textSize(16);
		float max = 0;
		for(E o : options) {
			max = max(max, ctx.textWidth(makeString(o)));
		}
		this.w((int) ceil(max) + 4 + 20);
		return (T) this;
	}

	public T value(E value) {
		selectedOption = max(0, options.indexOf(value));
		onChange.run();
		return (T) this;
	}

	public E value() {
		return options.isEmpty() ? null : options.get(selectedOption);
	}

	private String makeString(E item) {
		if (item.getClass() == Class.class) {
			return ((Class<?>) item).getSimpleName();
		} else {
			return String.valueOf(item);
		}
	}

	private class UIDropdownExpanded extends AbstractUIBasicElement<UIDropdownExpanded> {
		int hovering;

		public UIDropdownExpanded() {
			super(AbstractUIDropdown.this.ctx);
			this.hovering = 0;
			this.xy(AbstractUIDropdown.this.x + 5, AbstractUIDropdown.this.y + 10);
			this.wh(AbstractUIDropdown.this.w - 10, AbstractUIDropdown.this.options.size() * 24);
			this.onDraw = () -> {this._onDraw();};
			this.onClick = () -> {this._onClick();};
			this.onKeyDown = () -> {this._onKeyDown();};
			this.onHover = () -> {this._onHover();};
		}

		private void choose(int option) {
			AbstractUIDropdown.this.selectedOption = option;
			AbstractUIDropdown.this.onChange.run();
			AbstractUIDropdown.this.expanded = null;
			AbstractUIDropdown.this.ui.closePopup();
			AbstractUIDropdown.this.ui.focus(AbstractUIDropdown.this);
		}

		private void _onDraw() {
			for(int i = 0; i < options.size(); i++) {
				ctx.fill(220 + 10 * (i % 2));
				ctx.rect(this.x, this.y + 24 * i, this.w, 24);
				if(hovering == i) {
					ctx.fill(0, 0, 0, 40);
					ctx.rect(this.x, this.y + 24 * i, this.w, 24);
				}
				ctx.fill(0);
				ctx.textAlign(LEFT, CENTER);
				ctx.text(makeString(options.get(i)), this.x + 4, this.y + 24 * i + 12);
			}
		}

		private void _onClick() {
			choose((ctx.mouseY - this.y) / 24);
		}

		private void _onKeyDown() {
			switch(ctx.keyCode) {
			case UP:
				hovering = clamp(hovering - 1, 0, options.size() - 1);
				break;
			case DOWN:
				hovering = clamp(hovering + 1, 0, options.size() - 1);
				break;
			case ENTER:
			case RETURN:
				choose(hovering);
				break;
			}
		}

		private void _onHover() {
			hovering = ui.relY / 24;
		}
	}
}

public class UIDropdown<E> extends AbstractUIDropdown<UIDropdown<E>, E> {
	public UIDropdown(PApplet ctx) {
		super(ctx);
	}
}

public class AbstractUILabel<T extends AbstractUILabel<T>> extends AbstractUIBasicElement<T> {
	String label;
	int textSize;
	int textAlignX;
	int textAlignY;
	int r, g, b;

	public AbstractUILabel(PApplet ctx, String label) {
		super(ctx);
		this.textSize = 16;
		ctx.textSize(this.textSize);
		this.w((int) ctx.textWidth(label));
		this.h(this.textSize);
		this.label = label;
		this.textAlignX = LEFT;
		this.textAlignY = CENTER;
		this.r = this.g = this.b = 0;
		this.onDraw = () -> {
			this._onDraw();
		};
	}

	private void _onDraw() {
		ctx.fill(r, g, b);
		ctx.textSize(textSize);
		ctx.textAlign(textAlignX, textAlignY);
		ctx.text(label, x, y + h / 2);
	}

	public T colour(int r, int g, int b) {
		this.r = r;
		this.g = g;
		this.b = b;
		return (T) this;
	}

	public T align(int textAlignX, int textAlignY) {
		this.textAlignX = textAlignX;
		this.textAlignY = textAlignY;
		return (T) this;
	}

	public T size(int textSize) {
		this.textSize = textSize;
		this.h = textSize;
		return (T) this;
	}
}

public class UILabel extends AbstractUILabel<UILabel> {
	public UILabel(PApplet ctx, String label) {
		super(ctx, label);
	}
}

public abstract class AbstractUITextField<T extends AbstractUITextField<T>> extends AbstractUIBasicElement<T> implements HoldsValue<T, String> {
	String text;
	String placeholder;
	int textSize;
	int lines;
	int textAlignX;
	int cursorPos;
	int lineNumbers;
	int numberColW;
	int cursorBlinkStart;
	ArrayList<Integer> lineOffsets;
	boolean showCursor;
	Runnable onChange;

	public AbstractUITextField(PApplet ctx, int width, int lines) {
		super(ctx);
		this.wh(width, lines * 16 + 4);
		this.textSize = 16;
		this.lines = lines;
		this.textAlignX = LEFT;
		this.text = "";
		this.placeholder = "";
		this.onDraw = () -> {this._onDraw();};
		this.onClick = () -> {this._onClick();};
		this.onKeyDown = () -> {this._onKeyDown();};
		this.onFocus = () -> {this.showCursor = true;};
		this.onUnfocus = () -> {
			this.showCursor = false;
			this.onChange.run();
		};
		this.onChange = () -> {};
		this.cursorPos = -1;
		this.lineNumbers = lines > 1 ? 0 : -1;
		this.numberColW = 0;
		this.cursorBlinkStart = 0;
		this.lineOffsets = new ArrayList<>();
		this.showCursor = false;
	}

	private void setMainFont() {
		ctx.textSize(textSize);
		ctx.textAlign(textAlignX, TOP);
	}

	private void _onDraw() {
		ctx.fill(240);
		ctx.rect(x + numberColW, y, w - numberColW, h);
		lineOffsets.clear();
		setMainFont();

		char chars[] = (isEmpty() ? placeholder : text).toCharArray();
		int cumY = 0;
		int curChar = 0;
		int lineNumber = 0;
		String curLine;
		float curLen;
		boolean isContinuation;
		boolean lineFinished = true;
		while(curChar < chars.length) {
			curLine = "";
			curLen = 0;
			isContinuation = !lineFinished;
			lineFinished = false;
			lineOffsets.add(curChar);
			while(curLen < w - 4 - numberColW) {
				char c = chars[curChar];
				curChar++;
				curLine += c;
				curLen += ctx.textWidth(c);
				if(c == '\n' || curChar == chars.length) {
					lineFinished = true;
					break;
				}
			}
			if (!isContinuation)
				lineNumber++;
			if(!lineFinished) {
				int i = curLine.length() - 1;
				int ctype = Character.getType(curLine.charAt(i));
				while(i > 0 && Character.getType(curLine.charAt(i)) == ctype)
					i--;
				if (i == 0)
					i = curLine.length() - 1;
				curChar = curChar - (curLine.length() - i);
				curLine = curLine.substring(0, i);
			}
			String lineMarking = "";
			if (isContinuation)
				lineMarking = "→";
			else if(lineNumbers > 0 && (lineNumber - 1) % lineNumbers == 0)
				lineMarking = String.valueOf(lineNumber);
			ctx.fill(lineMarking == "→" ? 100 : 20);
			ctx.text(lineMarking, x + 1, y + 4 + cumY);
			ctx.fill(isEmpty() ? 100 : 0);
			ctx.text(curLine, x + 2 + numberColW, y + 4 + cumY, w - 4 - numberColW, h - 4);
			cumY += textSize;
		}
		if(lineOffsets.isEmpty())
			lineOffsets.add(0);
		if(showCursor && (millis() - cursorBlinkStart) % 1000 < 500) {
			if(cursorPos == -1)
				return;
			int i = getLineAtChar(cursorPos);
			ctx.fill(0);
			float textW = ctx.textWidth(text.substring(lineOffsets.get(i), cursorPos));
			if(textAlignX == LEFT)
				textW += 2;
			else if(textAlignX == CENTER)
				textW += ((this.w - numberColW) - textW) / 2;
			else if(textAlignX == RIGHT)
				textW = this.w - numberColW - 2;
			ctx.rect(x + numberColW + textW, y + i * textSize + 2, 0, textSize);
		}
	}

	private void _onClick() {
		placeCursorNear(ui.relX, ui.relY);
	}

	private void _onKeyDown() {
		if(cursorPos == -1)
			return;
		setMainFont();
		if(ctx.key == CODED) {
			int line = getLineAtChar(cursorPos);
			switch(ctx.keyCode) {
			case RIGHT:
				moveCursorBy(1);
				break;
			case LEFT:
				moveCursorBy(-1);
				break;
			case UP:
				placeCursorNear(numberColW + ctx.textWidth(text.substring(lineOffsets.get(line), cursorPos)), (line - 1) * textSize);
				break;
			case DOWN:
				placeCursorNear(numberColW + ctx.textWidth(text.substring(lineOffsets.get(line), cursorPos)), (line + 1) * textSize);
				break;
			case KeyEvent.VK_HOME:
				moveCursor(lineOffsets.get(line));
				break;
			case KeyEvent.VK_END:
				moveCursor(lineOffsets.get(line + 1) - 1);
				break;
			default:
				println(ctx.key);
			}
		} else {
			switch(ctx.key) {
			case BACKSPACE:
				if(cursorPos > 0)
					text = text.substring(0, cursorPos - 1) + text.substring(cursorPos, text.length());
				moveCursorBy(-1);
				break;
			case DELETE:
				if(cursorPos < text.length())
					text = text.substring(0, cursorPos) + text.substring(cursorPos + 1, text.length());
				break;
			default:
				text = text.substring(0, cursorPos) + ctx.key + text.substring(cursorPos, text.length());
				moveCursorBy(1);
			}
		}
	}

	private int getLineAtChar(int index) {
		int i = lineOffsets.size() - 1;
		while (lineOffsets.get(i) > index)
			i--;
		return i;
	}

	private void placeCursorNear(float x, int y) {
		int line = clamp(y / textSize, 0, lineOffsets.size() - 1);
		int i = lineOffsets.get(line);
		int iMax = line >= (lineOffsets.size() - 1) ? text.length() : (lineOffsets.get(line + 1) - 1);
		float cumX = numberColW + 2;
		while (cumX < x && i < iMax)
			cumX += ctx.textWidth(text.charAt(i++));
		moveCursor(i);
	}

	private void moveCursor(int n) {
		if(n == -1) {
			cursorPos = -1;
			return;
		}
		cursorPos = clamp(n, 0, text.length());
		cursorBlinkStart = millis();
	}

	private void moveCursorBy(int n) {
		moveCursor(cursorPos + n);
	}

	public String value() {
		return this.text;
	}

	public boolean isEmpty() {
		return text == "";
	}

	public T value(String text) {
		this.text = text == null ? "" : text;
		moveCursor(cursorPos);
		this.onChange.run();
		return (T) this;
	}

	public T onChange(Runnable onChange) {
		this.onChange = onChange;
		return (T) this;
	}

	public T textSize(int textSize) {
		this.textSize = textSize;
		return (T) this;
	}

	public T placeholder(String placeholder) {
		this.placeholder = placeholder;
		return (T) this;
	}

	public T alignX(int textAlignX) {
		this.textAlignX = textAlignX;
		return (T) this;
	}

	public T lineNumbers(int lineNumbers) {
		this.lineNumbers = lineNumbers;
		this.numberColW = lineNumbers >= 0 ? 12 : 0;
		return (T) this;
	}
}

public class UITextField extends AbstractUITextField<UITextField> {
	public UITextField(PApplet ctx, int width, int lines) {
		super(ctx, width, lines);
	}
}

public abstract class AbstractUIButton<T extends AbstractUIButton<T>> extends AbstractUIBasicElement<T> {
	String label;
	boolean pressed;
	boolean hovering;
	int labelSize;
	color neutralColor;
	color pressedColor;
	Runnable onHold;
	Future<?> holdThread;

	public AbstractUIButton(PApplet ctx) {
		super(ctx);
		this.label = "";
		this.pressed = false;
		this.hovering = false;
		this.labelSize = 16;
		this.neutralColor = color(240);
		this.pressedColor = color(180, 200, 220);
		this.onDraw = () -> {this._onDraw();};
		this.onKeyDown = () -> {this._onKeyDown();};
		this.onHover = () -> {this._onHover();};
		this.onLeave = () -> {this._onLeave();};
		this.onHold = () -> {};
	}

	private void _onDraw() {
		ctx.fill(pressed ? pressedColor : neutralColor);
		ctx.rect(x, y, w, h);
		if(hovering) {
			ctx.fill(0, 0, 0, 20);
			ctx.rect(x, y, w, h);
		}
		ctx.fill(0);
		ctx.textSize(labelSize);
		ctx.textAlign(CENTER, CENTER);
		ctx.text(label, x + w / 2, y + h / 2);
	}

	private void _onKeyDown() {
		if (ctx.keyCode == RETURN || ctx.keyCode == ENTER)
			this.onRelease.run();
	}

	private void _onHover() {
		this.hovering = true;
	}

	private void _onLeave() {
		this.pressed = false;
		this.hovering = false;
	}

	@Override
	public void click() {
		if (ctx.mouseButton != LEFT)
			return;
		pressed = true;
		threadpool.submit(() -> {this.onClick.run();});
		if (holdThread != null) holdThread.cancel(true);
		holdThread = threadpool.submit(() -> {
			delay(500);
			while(pressed) {
				threadpool.submit(() -> {this.onHold.run();});
				delay(50);
			}
		});
	}

	@Override
	public void release() {
		if (ctx.mouseButton != LEFT)
			return;
		this.pressed = false;
		if (holdThread != null) holdThread.cancel(true);
		this.onRelease.run();
	}

	public T label(String label) {
		this.label = label;
		return (T) this;
	}

	public T labelSize(int labelSize) {
		this.labelSize = labelSize;
		return (T) this;
	}

	public T neutralColor(color neutralColor) {
		this.neutralColor = neutralColor;
		return (T) this;
	}

	public T pressedColor(color pressedColor) {
		this.pressedColor = pressedColor;
		return (T) this;
	}

	public T onHold(Runnable onHold) {
		this.onHold = onHold;
		return (T) this;
	}

	public T onClickWithHold(Runnable onClickWithHold) {
		onClick(onClickWithHold);
		onHold(onClickWithHold);
		return (T) this;
	}
}

public class UIButton extends AbstractUIButton<UIButton> {
	public UIButton(PApplet ctx) {
		super(ctx);
	}
}

public abstract class AbstractUINumberInput<T extends AbstractUINumberInput<T>> extends AbstractUICompositeElement<T> implements HoldsValue<T, Integer> {
	int value;
	Runnable onChange;
	UITextField tField;

	public AbstractUINumberInput(PApplet ctx) {
		super(ctx);
		this.value = 0;
		this.wh(70, 20);
		this.onChange(() -> {});
		this.onScroll = () -> {this._onScroll();};

		this.children.add(new UIButton(ctx)
		.label("-")
		.xywh(0, 0, 20, 20)
		.onClickWithHold(() -> {decrement();})
		.onScroll(this.onScroll));
		this.children.add(new UIButton(ctx)
		.label("+")
		.xywh(50, 0, 20, 20)
		.onClickWithHold(() -> {increment();})
		.onScroll(this.onScroll));
		this.tField = new UITextField(ctx, 30, 1)
		.xywh(20, 0, 30, 20)
		.alignX(CENTER)
		.value(String.valueOf(this.value))
		.onScroll(this.onScroll)
		.onChange(() -> {this.readFromText();});
		this.children.add(tField);
	}

	private void _onScroll() {
		unfocusChild();
		this.value -= ui.scrollY;
		this.onChange.run();
	}

	private void readFromText() {
		int tValue = int(tField.value());
		if (tValue != this.value())
			this.value(int(tField.value()));
	}

	@Override
	public void keyUp() {
		tField.keyUp();
	}

	@Override
	public void keyDown() {
		switch(ctx.keyCode) {
		case UP:
		case KeyEvent.VK_ADD:
			unfocusChild();
			increment();
			break;
		case DOWN:
		case KeyEvent.VK_SUBTRACT:
			unfocusChild();
			decrement();
			break;
		default:
			focusChild(tField);
			tField.keyDown();
		}
	}

	public T onChange(Runnable onChange) {
		this.onChange = () -> {
			tField.value(Integer.toString(this.value));
			onChange.run();
		};
		return (T) this;
	}

	public T value(Integer value) {
		this.value = value;
		this.onChange.run();
		return (T) this;
	}

	public Integer value() {
		return this.value;
	}

	public void decrement() {
		value--;
		this.onChange.run();
	}

	public void increment() {
		value++;
		this.onChange.run();
	}
}

public class UINumberInput extends AbstractUINumberInput<UINumberInput> {
	public UINumberInput(PApplet ctx) {
		super(ctx);
	}
}

public abstract class AbstractUIShuffleList<T extends AbstractUIShuffleList<T, E>, E> extends AbstractUIBasicElement<T> {
	ArrayList<ListItem<E>> items;

	public AbstractUIShuffleList(PApplet ctx) {
		super(ctx);
		this.items = new ArrayList<>();
		this.onDraw = () -> {this._onDraw();};
	}

	private void _onDraw() {
		ctx.fill(200);
		ctx.rect(x, y, w, h);
		for(ListItem<E> item : items) {
			item.draw();
		}
	}

	public T addItems(E... items) {
		for(E item : items) {
			addItem(item);
		}
		return (T) this;
	}

	public ListItem<E> addItem(E item) {
		ListItem<E> newItem = new ListItem<>(item, this.items.size());
		this.items.add(newItem);
		ui.addElement(newItem);
		return newItem;
	}

	public void moveItem(int index, int n) {
		swap(items, index, clamp(index + n, 0, items.size() - 1));
		updateIndices();
	}

	public void removeItem(int index) {
		ui.removeElement(items.get(index));
		items.remove(index);
		updateIndices();
	}

	private void updateIndices() {
		for(int i = 0; i < items.size(); i++) {
			items.get(i).setIndex(i);
		}
	}

	public int numItems() {
		return items.size();
	}

	public E getItem(int i) {
		return items.get(i).value();
	}

	public void setItem(int i, E val) {
		this.items.get(i).value(val);
	}

	class ListItem<E> extends AbstractUICompositeElement<ListItem<E>> {
		E item;
		int index;
		AbstractUIShuffleList superthis;
		Runnable onChange;

		public ListItem(E item, int index) {
			super(AbstractUIShuffleList.this.ctx);
			this.superthis = AbstractUIShuffleList.this;
			this.item = item;
			this.wh(superthis.w(), 30);
			this.children.add(
			new UITextField(ctx, 30, 1)
			.xywh(0, 0, w - 90, 30)
			.value(String.valueOf(item)));
			this.children.add(
			new UIButton(ctx)
			.xywh(this.w - 90, 0, 30, 30)
			.label("↑")
			.onRelease(() -> this.moveUp())
			);
			this.children.add(
			new UIButton(ctx)
			.xywh(this.w - 60, 0, 30, 30)
			.label("↓")
			.onRelease(() -> this.moveDown())
			);
			this.children.add(
			new UIButton(ctx)
			.xywh(this.w - 30, 0, 30, 30)
			.label("X")
			.onRelease(() -> this.remove())
			);
			this.x(superthis.x());
			setIndex(index);
		}

		@Override public void draw() {
			ctx.fill(220);
			ctx.rect(x, y, w, h);
			super.draw();
		}

		public void moveUp() {
			superthis.moveItem(index, -1);
		}

		public void moveDown() {
			superthis.moveItem(index, 1);
		}

		public void remove() {
			superthis.removeItem(index);
		}

		public void setIndex(int index) {
			this.index = index;
			this.y(superthis.y() + index * 30);
		}

		public ListItem<E> value(E val) {
			this.item = val;
			this.onChange.run();
			return this;
		}

		public E value() {
			return this.item;
		}

		public ListItem<E> onChange(Runnable onChange) {
			this.onChange = onChange;
			return this;
		}
	}
}

public class UIShuffleList<E> extends AbstractUIShuffleList<UIShuffleList<E>, E> {
	public UIShuffleList(PApplet ctx) {
		super(ctx);
	}
}

public class UI {
	PApplet ctx;
	LinkedList<UIElement> elements;
	int scrollY;
	int relX;
	int relY;
	UIElement focus;
	UIElement popup;
	UIElement hover;

	public UI(PApplet ctx) {
		this.ctx = ctx;
		elements = new LinkedList<UIElement>();
	}

	public void draw() {
		ctx.background(220);

		for(UIElement e : elements) {
			if(focus == e) {
				ctx.stroke(50, 180, 20);
				ctx.noFill();
				int rightOffset = e instanceof UITextField ? ((UITextField) e).numberColW : 0;
				ctx.rect(e.x() + rightOffset - 1, e.y() - 1, e.w() - rightOffset + 2, e.h() + 2);
				ctx.stroke(0);
			}
			e.draw();
		}
	}

	public void addElement(UIElement e) {
		e.setUI(this);
		elements.add(e);
	}

	public void removeElement(UIElement e) {
		elements.remove(e);
	}

	public void focus(UIElement e) {
		if(focus != null && focus != e)
			focus.unfocus();
		focus = e;
		focus.focus();
	}

	public void unfocus() {
		if(focus != null)
			focus.unfocus();
		focus = null;
	}

	public void setPopup(UIElement e) {
		closePopup();
		addElement(e);
		popup = e;
		focus(popup);
	}

	public void closePopup() {
		if(popup != null)
			popup.unfocus();
		removeElement(popup);
		popup = null;
	}

	private void calcRelMouse(UIElement e, int x, int y) {
		relX = x - e.x();
		relY = y - e.y();
	}

	public void click(int x, int y, int button) {
		UIElement e = getTouchingElement(x, y);
		if(popup != null && e != popup) {
			closePopup();
			return;
		}
		if(e instanceof UITextField || e instanceof UIDropdown || e instanceof UIButton || e instanceof UINumberInput)
			focus(e);
		else
			unfocus();
		if(e != null)
			e.click();
	}

	public void release(int x, int y, int button) {
		UIElement e = getTouchingElement(x, y);
		if(hover != null && hover != e)
			hover.leave();
		else if(e != null) {
			e.release();
		}
	}

	public void scroll(int x, int y, int scroll) {
		this.scrollY = scroll;
		UIElement e = getTouchingElement(x, y);
		if(e != null)
			e.scroll();
	}

	public void keyUp(int x, int y, int key) {
		if(focus != null)
			focus.keyUp();
	}

	public void keyDown(int x, int y, int key) {
		if(key == ESC) {
			closePopup();
			unfocus();
			if(hover != null && !hover.touches(x, y)) {
				hover.leave();
				hover = null;
			}
		} else if(focus != null)
			focus.keyDown();
	}

	public void mouseMove(int x, int y, boolean pressed) {
		if(pressed)
			return;
		UIElement e = getTouchingElement(x, y);
		if(hover != null && hover != e)
			hover.leave();
		hover = e;
		if(e != null)
			e.hover();
	}

	public UIElement getTouchingElement(int x, int y) {
		ListIterator<UIElement> it = elements.listIterator(elements.size());
		while(it.hasPrevious()) {
			UIElement e = it.previous();
			if (e.touches(x, y)) {
				calcRelMouse(e, x, y);
				return e;
			}
		}
		return null;
	}

	public class FormBuilder {
		LinkedList<UIElement> currentRow;
		int padding = 4;
		int cumX, cumY;
		int maxH;

		public FormBuilder() {
			this.currentRow = new LinkedList<>();
			this.cumX = this.cumY = padding;
			this.maxH = 0;
		}

		public FormBuilder addRow(int feed) {
			for(UIElement e : currentRow) {
				e.h(maxH);
				UI.this.addElement(e);
			}

			cumY += maxH + feed + padding;
			cumX = padding;
			maxH = 0;
			currentRow.clear();

			return this;
		}

		public FormBuilder addRow() {
			return addRow(0);
		}

		public FormBuilder addRight(int feed, UIElement element) {
			element.x(cumX + feed);
			element.y(cumY);
			cumX += element.w() + feed + padding;
			maxH = max(maxH, element.h());
			currentRow.add(element);

			return this;
		}

		public FormBuilder addRight(UIElement element) {
			return addRight(currentRow.isEmpty() ? 0 : 8, element);
		}
	}
}
