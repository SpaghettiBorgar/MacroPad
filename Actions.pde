public abstract class Action {
	boolean triggered;
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

	public JSONObject serializeJSON() {
		JSONObject json = new JSONObject();
		json.setString("label", this.label);

		return json;
	}

	public void deserializeJSON(JSONObject json) {
		this.label = json.getString("label");
	}
}

public class TextAction extends Action {
	private String text;
	private int cursorShift;

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
