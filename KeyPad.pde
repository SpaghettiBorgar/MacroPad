import processing.serial.*;
import java.util.Map;
import java.util.concurrent.Future;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;

public final int PAGESIZE = 4;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port

ActionMatrix actions;
boolean sw = false;
ExecutorService threadpool = Executors.newCachedThreadPool();

public static int mod(int a, int b)
{
	return((a % b) + b) % b;
}

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
		
		int cursor = 0; //<>//
		int ei = 0;
		while((ei = text.indexOf("%", cursor)) != -1)
		{
			if (cursor < ei) //<>//
				type(text.substring(cursor, ei));
			cursor = ei + 1;
			if (text.charAt(cursor) == '%')
			{
				type("%");
				cursor++;
			}
			else // if(text.charAt(cursor) == '{')
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

public class ActionMatrix
{
	ArrayList<Action[][]> pages = new ArrayList<Action[][]>();
	private int curPage;
	
	public ActionMatrix()
	{
		curPage = 0;
	}
	
	private void touchPage(int page)
	{
		while(page >= pages.size())
		{
			Action newPage[][] = new Action[PAGESIZE][PAGESIZE];
			for (int y = 0; y < PAGESIZE; y++)
			{
				for (int x = 0; x < PAGESIZE; x++)
				{
					newPage[y][x] = new EmptyAction();
				}
			}
			pages.add(newPage);
		}
	}
	
	public Action getAction(int page, int row, int column)
	{
		touchPage(page);
		return pages.get(page)[row][column];
	}
	
	public Action getAction(int row, int column)
	{
		return getAction(curPage, row, column);
	}

	public void addAction(int page, int row, int column, Action action)
	{
		touchPage(page);
		pages.get(page)[row][column] = action;
	}
	
	void editAction(int row, int column)
	{
		ConfigureWindow window = new ConfigureWindow();
	}

	public int numPages()
	{
		return pages.size();
	}
	
	public void goPage(int page)
	{
		if (page >= 0)
			touchPage(page);
		curPage = mod(page, numPages());
	}

	public void changePage(int n)
	{
		curPage = mod(curPage + n, numPages());
	}

	public void nextPage()
	{
		changePage(1);
	}

	public void prevPage()
	{
		changePage( -1);
	}

	public int curPage()
	{
		return curPage;
	}
}

void setup()
{
	size(330, 370);
	// map.put("A", "Hello World!");
	// map.put("B", "meow");
	// map.put("C", "\\begin{itemize}\r\\item\r\\end{itemize}");
	// map.put("D", "nyaa~");
	
	setupPages();
	
	String portName = Serial.list()[0];
	myPort = new Serial(this, "/dev/ttyUSB0", 9600);
}

void setupPages()
{
	actions = new ActionMatrix();
	actions.addAction(0, 0, 0, new TextAction("test"));
	actions.addAction(0, 0, 1, new TextAction("meow"));
	actions.addAction(0, 0, 2, new TextAction("ABC", "abcdefghijklmnopqrstuvwxyz"));
	actions.addAction(0, 0, 3, new SpecialAction(SpecialActionType.NEXT_PAGE));
	actions.addAction(0, 1, 0, new TextAction("ε", "\\varepsilon "));
	actions.addAction(0, 1, 1, new TextAction("δ", "\\delta "));
	actions.addAction(0, 1, 3, new TextAction("*", "\\textasteriskcentered "));
	actions.addAction(0, 2, 0, new TextAction("mathrm", "\\mathrm{} ", -2));
	actions.addAction(0, 2, 1, new TextAction("text", "\\text{} ", -2));
	actions.addAction(0, 2, 2, new TextAction("(", "\\left( "));
	actions.addAction(0, 2, 3, new TextAction(")", "\\right) "));
	actions.addAction(0, 3, 2, new TextAction("cases", "\\begin{cases}%Return%Return\\end{cases}%Up%End"));
	actions.addAction(0, 3, 3, new TextAction("frac", "\\frac{}{}", -3));
}

void key(String keysym, int repeat)
{
	println("key " + keysym + " " + repeat);
	while(repeat > 0)
	{
		try{
			Runtime.getRuntime().exec(new String[] {"xdotool", "key", keysym}).waitFor();
		} catch(IOException | InterruptedException e) {
			e.printStackTrace();
		}
		repeat--;
	}
}

void key(String keysym)
{
	key(keysym, 1);
}

void type(String s)
{
	key("space");	// stupid workaround for obscure bug
	key("BackSpace");
	println("type " + s);
	// for (char c : s.toCharArray())
	// {
	// 	key(String.valueOf(c));
	// }
	try{
		Runtime.getRuntime().exec(new String[] {"xdotool", "type", s}).waitFor();
	} catch(IOException | InterruptedException e) {
		e.printStackTrace();
	}
}

void draw()
{
	if (myPort.available() > 0) {  // If data is available,
		val = myPort.readStringUntil('\n').trim();         // read it and store it in val
		switch(val.charAt(0))
		{
			case 'D':
				actions.getAction(val.charAt(2) - '0', val.charAt(1) - '0').trigger();
				break;
			case 'U':
				actions.getAction(val.charAt(2) - '0', val.charAt(1) - '0').untrigger();
				break;
			case 'R':
				actions.nextPage();
				break;
			case 'L':
				actions.prevPage();
				break;
			case 'S':
				switch(val.charAt(1))
				 {
					case 'D':
					sw = true;
					break;
				case 'U':
					sw = false;
					break;
			}
			break;
			default:
			println("Unhandled opcode: " + val);
		}
	}
	
	background(220);
	for (int x = 0; x < 4; x++)
	 {
		for (int y = 0; y < 4; y++)
		{
			Action action = actions.getAction(y, x);
			if (action.triggered)
				fill(200, 160, 0);
			else
				fill(120);
			rect(x * 80 + 10, y * 80 + 10, 70, 70);
			fill(20, 0, 0);
			textSize(14);
			textAlign(CENTER, CENTER);
			text(action.getLabel(), x * 80 + 45, y * 80 + 45);
		}
	}
	if (sw)
		fill(200, 160, 0);
	else
		fill(80);
	textSize(32);
	textAlign(CENTER, CENTER);
	text("Page " + (actions.curPage() + 1) + "/" + actions.numPages(), 168, 344);
}

void mousePressed()
{
	int i = mouseX / 80;
	int j = mouseY / 80;
	if (i >= PAGESIZE || j >= PAGESIZE)
		return;
	
	if (mouseButton == LEFT)
		actions.getAction(j, i).trigger();
	else if (mouseButton == RIGHT)
		actions.editAction(j, i);
}

void mouseReleased()
{
	int i = mouseX / 80;
	int j = mouseY / 80;
	if (i >= PAGESIZE || j >= PAGESIZE)
		return;
	
	if (mouseButton == LEFT)
		actions.getAction(j, i).untrigger();
}

class ConfigureWindow extends PApplet
{
	public ConfigureWindow()
	 {
		super();
		PApplet.runSketch(new String[] {this.getClass().getName()}, this);
	}
}
