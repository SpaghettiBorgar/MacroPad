public static int mod(int a, int b)
{
	return((a % b) + b) % b;
}

void execSync(String args[])
{
	try {
		Runtime.getRuntime().exec(args).waitFor();
	} catch(IOException | InterruptedException e) {
		e.printStackTrace();
	}
}

Future<?> execAsync(String args[])
{
	return threadpool.submit(()->execSync(args));
}

void prepareText() // stupid workaround for obscure bug
{
	execSync(new String[] {"xdotool", "key", "space"});
	execSync(new String[] {"xdotool", "key", "BackSpace"});
}

void key(String keysym, int repeat)
{
	println("key " + keysym + " " + repeat);
	while(repeat > 0)
	{
		execSync(new String[] {"xdotool", "key", keysym});
		repeat--;
	}
}

void key(String keysym)
{
	key(keysym, 1);
}

void type(String s)
{
	execSync(new String[] {"xdotool", "type", s});
}
