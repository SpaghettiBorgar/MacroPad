public abstract class Action
{
	boolean triggered;
	String label;

	protected abstract void _trigger();

	public void trigger()
	{
		triggered = true;
		threadpool.submit(() -> _trigger());
	}

	public void untrigger()
	{
		triggered = false;
	}

	public String getLabel()
	{
		return label == null ? "" : label;
	}
}

public class TextAction extends Action
{
	private String text;
	private int cursorShift;

	public TextAction(String label, String text, int cursorShift)
	{
		this.label = label;
		this.text = text;
		this.cursorShift = cursorShift;
	}

	public TextAction(String label, String text)
	{
		this(label, text, 0);
	}

	public TextAction(String text)
	{
		this(null, text, 0);
	}

	@Override
	void _trigger()
	{
		println("Typing: " + text);

		prepareText();

		int cursor = 0;
		int ei = 0;
		while((ei = text.indexOf("%", cursor)) != -1)
		{
			if (cursor < ei)
				type(text.substring(cursor, ei));
			cursor = ei + 1;
			if (text.charAt(cursor) == '%')
			{
				type("%");
				cursor++;
			}
			else
			{
				ei = cursor;
				while(ei < text.length())
				{
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
	public String getLabel()
	{
		return label == null ? text : label;
	}
}

public static enum SpecialActionType
{
	NEXT_PAGE,
	PREV_PAGE
}

public class SpecialAction extends Action
{
	SpecialActionType type;

	public SpecialAction(SpecialActionType type)
	{
		this.type = type;
	}

	@Override
	void _trigger()
	{
		switch(type)
		{
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
	String getLabel()
	{
		switch(type)
		{
		case NEXT_PAGE:
			return "→";
		case PREV_PAGE:
			return "←";
		default:
			return "";
		}
	}
}

public class EmptyAction extends Action
{
	public EmptyAction()
	{

	}

	@Override
	void _trigger() {}
}
