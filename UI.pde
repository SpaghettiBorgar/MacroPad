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
}

public abstract class AbstractUIBasicElement<T extends AbstractUIBasicElement<T>> implements UIElement<T> {
	PApplet ctx;
	UI ui;
	int x, y, w, h;
	Runnable onDraw, onClick, onRelease, onScroll;

	public AbstractUIBasicElement(PApplet ctx) {
		this.ctx = ctx;
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
		for (UIElement child : children) {
			child.draw();
		}
	}

	public void click() {
		UIElement e = getTouchingChild();
		if(e != null) {
			e.click();
		} else {
			super.click();
		}
	}

	public void release() {
		UIElement e = getTouchingChild();
		if(e != null) {
			e.release();
		} else {
			super.release();
		}
	}

	public void scroll() {
		UIElement e = getTouchingChild();
		if(e != null) {
			e.scroll();
		} else {
			super.scroll();
		}
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

public class UIBasicElement extends AbstractUIBasicElement<UIBasicElement> {
	public UIBasicElement(PApplet ctx) {
		super(ctx);
	}
}

public abstract class AbstractUIDropdown<T extends AbstractUIDropdown<T, E>, E> extends AbstractUIBasicElement<T> implements HoldsValue<T, E> {
	ArrayList<E> options;
	int selectedOption;
	UIDropdownExpanded expanded;
	Runnable onSelect;

	public AbstractUIDropdown(PApplet ctx) {
		super(ctx);
		this.h(20);
		this.options = new ArrayList<>();
		this.expanded = null;
		this.onDraw = () -> {this._onDraw();};
		this.onClick = () -> {this._onClick();};
		this.onScroll = () -> {this._onScroll();};
		this.onSelect = () -> {};
	}

	private void _onDraw() {
		ctx.fill(160);
		ctx.rect(this.x, this.y, this.w, this.h);
		ctx.fill(0, 0, 0);
		ctx.textSize(16);
		ctx.textAlign(LEFT, CENTER);
		ctx.text(options.isEmpty() ? "—" : String.valueOf(options.get(selectedOption)), this.x + 2, this.y + this.h / 2);
	}

	private void _onClick() {
		if (expanded == null) {
			expanded = new UIDropdownExpanded();
			ui.addElement(expanded);
		}
	}

	private void _onScroll() {
		selectedOption = options.isEmpty() ? 0 : clamp(selectedOption + ui.scrollY, 0, options.size() - 1);
	}

	public T onSelect(Runnable onSelect) {
		this.onSelect = onSelect;
		return (T) this;
	}

	public T addOptions(E... options) {
		this.options.addAll(Arrays.asList(options));
		float max = 0;
		for(E o : options) {
			max = max(max, ctx.textWidth(String.valueOf(o)));
		}
		this.w((int) ceil(max) + 4);
		return (T) this;
	}

	public T value(E value) {
		selectedOption = max(0, options.indexOf(value));
		onSelect.run();
		return (T) this;
	}

	public E value() {
		return options.isEmpty() ? null : options.get(selectedOption);
	}

	private class UIDropdownExpanded extends AbstractUIBasicElement<UIDropdownExpanded> {
		public UIDropdownExpanded() {
			super(AbstractUIDropdown.this.ctx);
			this.xy(AbstractUIDropdown.this.x, AbstractUIDropdown.this.y);
			this.wh(AbstractUIDropdown.this.w, AbstractUIDropdown.this.options.size() * 20);
			this.onDraw = () -> {this._onDraw();};
			this.onClick = () -> {this._onClick();};
		}
		private void _onDraw() {
			for(int i = 0; i < options.size(); i++) {
				String opt = String.valueOf(options.get(i));
				ctx.fill(180 + 20 * (i % 2));
				ctx.rect(this.x, this.y + 20 * i, this.w, 20);
				ctx.fill(0);
				ctx.textAlign(LEFT, CENTER);
				ctx.text(opt, this.x + 2, this.y + 20 * i + 10);
			}
		}
		private void _onClick() {
			AbstractUIDropdown.this.selectedOption = (ctx.mouseY - this.y) / 20;
			AbstractUIDropdown.this.onSelect.run();
			AbstractUIDropdown.this.expanded = null;
			AbstractUIDropdown.this.ui.removeElement(this);
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

	public AbstractUITextField(PApplet ctx, int width, int lines) {
		super(ctx);
		this.wh(width, lines * 16 + 4);
		this.textSize = 16;
		this.lines = lines;
		this.placeholder = "";
		this.onDraw = () -> {this._onDraw();};
	}

	private void _onDraw() {
		ctx.fill(240);
		ctx.rect(x, y, w, h);
		ctx.fill(text == null ? 120 : 0);
		ctx.textSize(textSize);
		ctx.textAlign(textAlignX, TOP);
		ctx.text(text == null ? placeholder : text, x + 2, y + 4, w - 4, h - 4);
	}

	public String value() {
		return this.text;
	}

	public T value(String text) {
		this.text = text;
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
}

public class UITextField extends AbstractUITextField<UITextField> {
	public UITextField(PApplet ctx, int width, int lines) {
		super(ctx, width, lines);
	}
}

public abstract class AbstractUIButton<T extends AbstractUIButton<T>> extends AbstractUIBasicElement<T> {
	String label;
	boolean pressed;
	int labelSize;
	color neutralColor;
	color pressedColor;
	Runnable onHold;
	Future<?> holdThread;

	public AbstractUIButton(PApplet ctx) {
		super(ctx);
		this.label = "";
		this.pressed = false;
		this.labelSize = 16;
		this.neutralColor = color(240);
		this.pressedColor = color(180, 200, 220);
		this.onDraw = () -> {this._onDraw();};
		this.onHold = () -> {};
	}

	private void _onDraw() {
		ctx.fill(pressed ? pressedColor : neutralColor);
		ctx.rect(x, y, w, h);
		ctx.fill(0);
		ctx.textSize(labelSize);
		ctx.textAlign(CENTER, CENTER);
		ctx.text(label, x + w / 2, y + h / 2);
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
		this.onScroll = () -> {
			this.value -= ui.scrollY;
			this.onChange.run();
		};
		this.onDraw = () -> {this._onDraw();};
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
		.xywh(20, 0, 33, 20)
		.alignX(CENTER)
		.value(String.valueOf(this.value))
		.onScroll(this.onScroll);
		this.children.add(tField);
	}

	private void _onDraw() {
		ctx.fill(240);
		ctx.rect(x + 20, y, 30, 20);
		ctx.fill(0);
		ctx.textSize(16);
		ctx.textAlign(CENTER, CENTER);
		ctx.text(String.valueOf(value), x + w / 2, y + h / 2);
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

public class UI {
	PApplet ctx;
	LinkedList<UIElement> elements;
	int scrollY;

	public UI(PApplet ctx) {
		this.ctx = ctx;
		elements = new LinkedList<UIElement>();
	}

	public void draw() {
		ctx.background(220);

		for(UIElement e : elements) {
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
		this.scrollY = scroll;
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
			return addRight(0, element);
		}
	}
}
