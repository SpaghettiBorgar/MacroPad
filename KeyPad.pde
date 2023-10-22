import processing.serial.*;
import java.util.Map;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.ListIterator;
import java.util.concurrent.Future;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;

public static final int PAGESIZE = 4;
public static final int TILESIZE = 80;

Serial serialPort;
ActionMatrix actions;
boolean sw = false;
ExecutorService threadpool = Executors.newCachedThreadPool();
UI ui;
int mouseScroll;

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

void readSerial()
{
	if (serialPort.available() > 0) {
		String val = serialPort.readStringUntil('\n').trim();
		println(val);
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
}

void setup()
{
	size(330, 370);
	setupPages();
	setupUI();

	String portName = Serial.list()[0];
	println(portName);
	portName = "/dev/ttyUSB0"; // tmp
	serialPort = new Serial(this, portName, 9600);

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

void setupUI()
{
	ui = new UI();

	ui.addElement(new UIElement(0, 0, width, height, ()-> {}, ()-> {}, ()-> {}, ()-> {actions.changePage(mouseScroll);}));

	for (int j = 0; j < PAGESIZE; j++)
	{
		for (int i = 0; i < PAGESIZE; i++)
		{
			final int frow = j, fcol = i;
			final Action action = actions.getAction(j, i);
			final int x = i * TILESIZE + 10, y = j * TILESIZE + 10, w = TILESIZE - 10, h = TILESIZE - 10;

			ui.addElement(new UIElement(x, y, w, h,
			()-> {
				if (action.triggered)
					fill(200, 160, 0);
				else
					fill(120);
				rect(x, y, w, h);
				fill(20, 0, 0);
				textSize(14);
				textAlign(CENTER, CENTER);
				text(action.getLabel(), x + 35, y + 35);
			},
			() -> {
				if(mouseButton == LEFT)
					action.trigger();
				else if(mouseButton == RIGHT)
					edit(frow, fcol);
			},
			() -> {
				action.untrigger();
			},
			()-> {}));
		}
	}

	ui.addElement(new UIElement(0, TILESIZE * PAGESIZE + 10, TILESIZE * PAGESIZE + 10, 40,
	()-> {
		if (sw)
			fill(200, 160, 0);
		else
			fill(80);
		textSize(32);
		textAlign(CENTER, CENTER);
		text("Page " + (actions.curPage() + 1) + "/" + actions.numPages(), 168, 344);
	},
	()-> {},
	()-> {},
	()-> {}));
}

void draw()
{
	readSerial();

	background(220);

	ui.draw();
}

void trigger(int row, int col)
{
	actions.getAction(row, col).trigger();
}

void untrigger(int row, int col)
{
	actions.getAction(row, col).untrigger();
}

void edit(int row, int col)
{
	actions.editAction(row, col);
}

void mousePressed()
{
	ui.click(mouseX, mouseY, mouseButton);
}

void mouseReleased()
{
	ui.release(mouseX, mouseY, mouseButton);
}

void mouseWheel(MouseEvent e)
{
	ui.scroll(mouseX, mouseY, e.getCount());
}
