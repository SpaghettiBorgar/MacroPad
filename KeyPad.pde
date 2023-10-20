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
int page = 0;
ExecutorService threadpool = Executors.newCachedThreadPool();

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
				page = (page + 1) % actions.numPages();
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
	
	public ActionMatrix()
	{
		
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
	
	public void addAction(int page, int row, int column, Action action)
	{
		touchPage(page);
		pages.get(page)[row][column] = action;
	}
	
	public int numPages()
	{
		return pages.size();
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
	actions.addAction(1, 0, 0, new TextAction("test"));
	actions.addAction(1, 0, 1, new TextAction("meow"));
	actions.addAction(1, 0, 2, new TextAction("ABC", "abcdefghijklmnopqrstuvwxyz"));
	actions.addAction(1, 0, 3, new SpecialAction(SpecialActionType.NEXT_PAGE));
	actions.addAction(1, 1, 0, new TextAction("ε", "\\varepsilon "));
	actions.addAction(1, 1, 1, new TextAction("δ", "\\delta "));
	actions.addAction(1, 1, 3, new TextAction("*", "\\textasteriskcentered "));
	actions.addAction(1, 2, 0, new TextAction("mathrm", "\\mathrm{} ", -2));
	actions.addAction(1, 2, 1, new TextAction("text", "\\text{} ", -2));
	actions.addAction(1, 2, 2, new TextAction("(", "\\left( "));
	actions.addAction(1, 2, 3, new TextAction(")", "\\right) "));
	actions.addAction(1, 3, 2, new TextAction("cases", "\\begin{cases}%Return%Return\\end{cases}%Up%End"));
	actions.addAction(1, 3, 3, new TextAction("frac", "\\frac{}{}", -3));
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
				actions.getAction(page, val.charAt(2) - '0', val.charAt(1) - '0').trigger();
				break;
			case 'U':
				actions.getAction(page, val.charAt(2) - '0', val.charAt(1) - '0').untrigger();
				break;
			case 'R':
				page++;
				break;
			case 'L':
				page--;
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
			Action action = actions.getAction(page, y, x);
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
	text("Page " + page + "/5", 168, 344);
}

void mousePressed()
{
	int i = mouseX / 80;
	int j = mouseY / 80;
	if (i >= PAGESIZE || j >= PAGESIZE)
		return;
	
	if (mouseButton == LEFT)
		actions.getAction(page, j, i).trigger();
	else if (mouseButton == RIGHT)
		edit(i, j);
}

void mouseReleased()
{
	int i = mouseX / 80;
	int j = mouseY / 80;
	if (i >= PAGESIZE || j >= PAGESIZE)
		return;
	
	if (mouseButton == LEFT)
		actions.getAction(page, j, i).untrigger();
}

void edit(int i, int j)
{
	ConfigureWindow window = new ConfigureWindow();
}

void trigger(int page, int x, int y)
{
	
}

class ConfigureWindow extends PApplet
{
	public ConfigureWindow()
	 {
		super();
		PApplet.runSketch(new String[]{this.getClass().getName()} , this); 
	}
}
