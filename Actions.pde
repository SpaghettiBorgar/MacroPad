public static final Class<?> ACTION_CLASSES[] = {EmptyAction.class, TextAction.class, SpecialAction.class};

public interface IReflectProperties {
	public LinkedHashMap<String, Class<?>> getProperties();
	public <T> T getProperty(String name);
	public <T> void setProperty(String name, T value);
}

public interface ISerializeJSON {
	public JSONObject serializeJSON();
	public void deserializeJSON(JSONObject json);
}

public abstract class Action implements IReflectProperties, ISerializeJSON {
	transient boolean triggered;
	String label;

	protected abstract void _trigger();

	public void trigger() {
		triggered = true;
		threadpool.submit(() -> _trigger());
	}

	public void untrigger() {
		triggered = false;
	}

	public String getLabel() {
		return label == null ? "" : label;
	}

	@Override
	public JSONObject serializeJSON() {
		JSONObject json = new JSONObject();
		json.setString("label", this.label);

		return json;
	}

	@Override
	public void deserializeJSON(JSONObject json) {
		this.label = json.getString("label");
	}

	@Override
	public LinkedHashMap<String, Class<?>> getProperties() {
		Stack<Class<?>> classStack = new Stack<>();
		classStack.push(this.getClass());
		while(classStack.peek() != Action.class) {
			classStack.push(classStack.peek().getSuperclass());
		}
		LinkedHashMap<String, Class<?>> list = new LinkedHashMap<>();
		while(!classStack.isEmpty()) {
			Class<?> clazz = classStack.pop();
			for (Field field : clazz.getDeclaredFields()) {
				if(!field.isSynthetic() && !Modifier.isTransient(field.getModifiers())) {
					list.put(field.getName(), field.getType());
				}
			}
		}
		return list;
	}

	private Field getField(String name) throws NoSuchFieldException {
		Stack<Class<?>> classStack = new Stack<>();
		classStack.push(this.getClass());
		while(classStack.peek() != Action.class) {
			classStack.push(classStack.peek().getSuperclass());
		}
		while(!classStack.isEmpty()) {
			Class<?> clazz = classStack.pop();
			try {
				return clazz.getDeclaredField(name);
			} catch (NoSuchFieldException e) {
				continue;
			}
		}
		throw new NoSuchFieldException();
	}

	@Override
	public <T> T getProperty(String name) {
		try {
			return (T) getField(name).get(this);
		} catch(NoSuchFieldException | IllegalAccessException e) {
			e.printStackTrace();
			return null;
		}
	}

	@Override
	public <T> void setProperty(String name, T value) {
		try {
			getField(name).set(this, value);
		} catch(NoSuchFieldException | IllegalAccessException e) {
			e.printStackTrace();
		}
	}
}

public class TextAction extends Action {
	String text;
	int cursorShift;

	public TextAction(String label, String text, int cursorShift) {
		this.label = label;
		this.text = text;
		this.cursorShift = cursorShift;
	}

	public TextAction(String label, String text) {
		this(label, text, 0);
	}

	public TextAction(String text) {
		this(null, text, 0);
	}

	public TextAction() {

	}

	@Override
	void _trigger() {
		println("Typing: " + text);

		prepareText();

		int cursor = 0;
		int ei = 0;
		while((ei = text.indexOf("%", cursor)) != -1) {
			if (cursor < ei)
				type(text.substring(cursor, ei));
			cursor = ei + 1;
			if (text.charAt(cursor) == '%') {
				type("%");
				cursor++;
			} else {
				ei = cursor;
				while(ei < text.length()) {
					char c = text.charAt(ei);
					if (Character.isLetter(c) || Character.isDigit(c) || c == '_')
						ei++;
					else
						break;
				}
				key(text.substring(cursor, ei));
				cursor = ei;
			}
		}
		if (cursor < text.length())
			type(text.substring(cursor));

		if (cursorShift != 0)
			key(cursorShift < 0 ? "Left" : "Right", Math.abs(cursorShift));
	}

	@Override
	public String getLabel() {
		return label == null ? text : label;
	}

	public String getText() {
		return text;
	}

	@Override
	public JSONObject serializeJSON() {
		JSONObject json = super.serializeJSON();

		json.setString("text", this.text);
		json.setInt("cursorShift", this.cursorShift);

		return json;
	}

	@Override
	public void deserializeJSON(JSONObject json) {
		super.deserializeJSON(json);

		this.text = json.getString("text");
		this.cursorShift = json.getInt("cursorShift");
	}
}

public static enum SpecialActionType {
	INVALID,
	NEXT_PAGE,
	PREV_PAGE
}

public class SpecialAction extends Action {
	SpecialActionType type;

	public SpecialAction(SpecialActionType type) {
		this.type = type;
	}

	public SpecialAction() {

	}

	@Override
	void _trigger() {
		switch(type) {
		case NEXT_PAGE:
			actions.nextPage();
			break;
		case PREV_PAGE:
			actions.prevPage();
			break;
		default:
			println("Unhandled SpecialActionType " + type);
			break;
		}
	}

	@Override
	String getLabel() {
		switch(type) {
		case NEXT_PAGE:
			return "→";
		case PREV_PAGE:
			return "←";
		default:
			return "";
		}
	}

	@Override
	public JSONObject serializeJSON() {
		JSONObject json = super.serializeJSON();

		json.setString("specialType", this.type.name());

		return json;
	}

	@Override
	public void deserializeJSON(JSONObject json) {
		super.deserializeJSON(json);

		this.type = SpecialActionType.valueOf(json.getString("specialType"));
	}
}

public class EmptyAction extends Action {
	public EmptyAction() {

	}

	@Override
	void _trigger() {}
}
