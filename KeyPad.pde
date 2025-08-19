import processing.serial.*;

import java.util.*;
import java.awt.event.KeyEvent;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.function.Consumer;
import java.util.concurrent.Future;
import java.util.concurrent.Executors;
import java.util.concurrent.ExecutorService;

import com.github.kwhat.jnativehook.GlobalScreen;
import com.github.kwhat.jnativehook.NativeHookException;
import com.github.kwhat.jnativehook.keyboard.NativeKeyEvent;
import com.github.kwhat.jnativehook.keyboard.NativeKeyListener;

public static final int PAGESIZE = 4;
public static final int TILESIZE = 80;

Serial serialPort;
ActionMatrix actions;
boolean sw = false;
ExecutorService threadpool = Executors.newCachedThreadPool();
UI ui;
int mouseScroll;
UIGroup buttons;

public class GlobalKeyListener implements NativeKeyListener {
	final int[][] KEYMAP = {
		{ 8,  9, 10, 11},
		{22, 23, 24, 25},
		{36, 37, 38, 39},
		{50, 51, 52, 53}
	};
	boolean[][] latchmap = new boolean[4][4];

	public void nativeKeyPressed(NativeKeyEvent e) {
		System.out.println("Key Pressed: " + NativeKeyEvent.getKeyText(e.getKeyCode()));
		System.out.println(e.getKeyCode());
		System.out.println(e.getRawCode());
		System.out.println(e.getKeyLocation());
		if (e.getKeyCode() == NativeKeyEvent.VC_ESCAPE) {
			try {
				GlobalScreen.unregisterNativeHook();
			} catch(NativeHookException ex) {
				System.err.println("There was a problem unregistering the native hook.");
				System.err.println(ex.getMessage());
			}
		} else {
			int keyCode = e.getKeyCode();
			for (int y = 0; y < 4; y++) {
				for (int x = 0; x < 4; x++) {
					if (KEYMAP[y][x] == keyCode) {
						if (latchmap[y][x] == false) {
							latchmap[y][x] = true;
							actions.trigger(y, x);
						}
						return;
					}
				}
			}
		}
	}

	public void nativeKeyReleased(NativeKeyEvent e) {
		System.out.println("Key Released: " + NativeKeyEvent.getKeyText(e.getKeyCode()));
		int keyCode = e.getKeyCode();
		for (int y = 0; y < 4; y++) {
			for (int x = 0; x < 4; x++) {
				if (KEYMAP[y][x] == keyCode) {
					latchmap[y][x] = false;
					actions.untrigger(y, x);
					return;
				}
			}
		}
	}

	public void nativeKeyTyped(NativeKeyEvent e) {
		System.out.println("Key Typed: " + e.getKeyText(e.getKeyCode()));
	}
}

public class ActionMatrix {
	ArrayList<Action[][]> pages = new ArrayList<Action[][]>();
	ArrayList<String> pageNames = new ArrayList<String>();
	private int curPage;

	public ActionMatrix() {
		curPage = 0;
	}

	public int addPage(String name) {
		Action newPage[][] = new Action[PAGESIZE][PAGESIZE];
		for (int y = 0; y < PAGESIZE; y++) {
			for (int x = 0; x < PAGESIZE; x++) {
				newPage[y][x] = new EmptyAction();
			}
		}
		pages.add(newPage);
		pageNames.add(name);
		return pages.size() - 1;
	}

	public int addPage() {
		return addPage("Page " + (pages.size() + 1));
	}

	private void touchPage(int page) {
		while(page >= pages.size()) {
			addPage();
		}
	}

	public Action getAction(int page, int row, int column) {
		touchPage(page);
		return pages.get(page)[row][column];
	}

	public Action getAction(int row, int column) {
		return getAction(curPage, row, column);
	}

	public void addAction(int page, int row, int column, Action action) {
		touchPage(page);
		pages.get(page)[row][column] = action;
	}

	void editAction(int row, int column) {
		ConfigureWindow window = new ConfigureWindow(getAction(row, column), (action) -> {
			addAction(curPage, row, column, action);
			setupButtons();
			storePages();
		});
	}

	void trigger(int row, int column) {
		getAction(row, column).trigger();
	}

	void untrigger(int row, int column) {
		getAction(row, column).untrigger();
	}

	public int numPages() {
		return pages.size();
	}

	public void goPage(int page) {
		if (page >= 0)
			touchPage(page);
		curPage = mod(page, numPages());
	}

	public void changePage(int n) {
		curPage = mod(curPage + n, numPages());
		setupButtons();
	}

	public void nextPage() {
		changePage(1);
	}

	public void prevPage() {
		changePage( -1);
	}

	public int curPage() {
		return curPage;
	}
}

void readSerial() {
	if (serialPort == null || !(serialPort.available() > 0))
		return;

	String val = serialPort.readStringUntil('\n').trim();
	println(val);
	switch(val.charAt(0)) {
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
		switch(val.charAt(1)) {
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

void setup() {
	size(330, 370);
	setupPages();
	setupUI();

	if(Serial.list().length >= 1) {
		String portName = Serial.list()[0];
		portName = "/dev/ttyUSB0";
		println("Using serial port " + portName);
    try {
		  serialPort = new Serial(this, portName, 9600);
    } catch(Exception e) {
      e.printStackTrace();
      serialPort = null;
    }
	} else {
		println("No serial devices found!");
	}

	try {
		GlobalScreen.registerNativeHook();
	} catch (NativeHookException ex) {
		System.err.println("There was a problem registering the native hook.");
		System.err.println(ex.getMessage());
	}
	// GlobalScreen.addNativeKeyListener(new GlobalKeyListener());
}

void setupPages() {
	actions = new ActionMatrix();

	restorePages();
}

void setupButtons() {
	buttons = new UIGroup(this);
	ui.addElement(buttons);

	for (int j = 0; j < PAGESIZE; j++) {
		for (int i = 0; i < PAGESIZE; i++) {
			final int frow = j, fcol = i;
			final Action action = actions.getAction(j, i);
			final int x = i * TILESIZE + 10, y = j * TILESIZE + 10, w = TILESIZE - 10, h = TILESIZE - 10;

			buttons.add(new UIBasicElement(this)
			.xywh(x, y, w, h)
			.onDraw(()-> {
				if (action.triggered)
					fill(200, 160, 0);
				else
					fill(120);
				rect(x, y, w, h);
				fill(20, 0, 0);
				textSize(14);
				textAlign(CENTER, CENTER);
				text(action.getLabel(), x + 35, y + 35);
			})
			.onClick(() -> {
				if(mouseButton == LEFT)
					action.trigger();
				else if(mouseButton == RIGHT)
					edit(frow, fcol);
			})
			.onRelease(() -> {
				action.untrigger();
			}));
		}
	}
}

void setupUI() {
	ui = new UI(this);

	ui.addElement(new UIBasicElement(this)
	.xywh(0, 0, width, height)
	.onScroll(()-> {
		actions.changePage(mouseScroll);
	}));

	setupButtons();

	ui.addElement(new UIBasicElement(this)
	.xywh(0, TILESIZE * PAGESIZE + 10, TILESIZE * PAGESIZE + 10, 40)
	.onDraw(()-> {
		if (sw)
			fill(200, 160, 0);
		else
			fill(80);
		textSize(32);
		textAlign(CENTER, CENTER);
		String pageName = actions.pageNames.get(actions.curPage());
		text((pageName == null ? "Page " : pageName) + " (" + (actions.curPage() + 1) + "/" + actions.numPages() + ")", 168, 344);
	})
	.onScroll(() -> {
		actions.changePage(ui.scrollY);
	})
	.onRelease(() -> {
		if(mouseButton == RIGHT) {
			new PagesWindow(actions, () -> {
				actions.goPage(clamp(actions.curPage, 0, actions.numPages() - 1));
				setupButtons();
				storePages();
			});
		}
	}));
}

void draw() {
	readSerial();

	ui.draw();
}

void trigger(int row, int col) {
	actions.getAction(row, col).trigger();
}

void untrigger(int row, int col) {
	actions.getAction(row, col).untrigger();
}

void edit(int row, int col) {
	actions.editAction(row, col);
}

void mousePressed() {
	ui.click(mouseX, mouseY, mouseButton);
}

void mouseReleased() {
	ui.release(mouseX, mouseY, mouseButton);
}

void mouseWheel(MouseEvent e) {
	ui.scroll(mouseX, mouseY, e.getCount());
}

void keyPressed() {
	ui.keyDown(mouseX, mouseY, key);
}

void keyReleased() {
	ui.keyUp(mouseX, mouseY, key);
}

void mouseMoved() {
	ui.mouseMove(mouseX, mouseY, false);
}

void mouseDragged() {
	ui.mouseMove(mouseX, mouseY, true);
}
