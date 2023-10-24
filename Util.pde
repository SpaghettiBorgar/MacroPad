public static int mod(int a, int b) {
	return((a % b) + b) % b;
}

public static <T extends Comparable<T>> T clamp(T val, T min, T max) {
	if (val.compareTo(min) < 0) {
		return min;
	} else if (val.compareTo(max) > 0) {
		return max;
	} else {
		return val;
	}
}

public static String[] getEnumNames(Class<? extends Enum<?>> e) {
	return Arrays.stream(e.getEnumConstants()).map(Enum::name).toArray(String[]::new);
}

public LinkedHashMap<String, Class<?>> getClassProperties(Class<?> clazz) {
	LinkedHashMap<String, Class<?>> list = new LinkedHashMap<>();
	for (Field field : clazz.getDeclaredFields()) {
		if(!Modifier.isTransient(field.getModifiers())) {
			list.put(field.getName(), field.getType());
		}
	}
	return list;
}

void execSync(String args[]) {
	try {
		Runtime.getRuntime().exec(args).waitFor();
	} catch(IOException | InterruptedException e) {
		e.printStackTrace();
	}
}

Future<?> execAsync(String args[]) {
	return threadpool.submit(()->execSync(args));
}

void prepareText() { // stupid workaround for obscure bug
	execSync(new String[] {"xdotool", "key", "space"});
	execSync(new String[] {"xdotool", "key", "BackSpace"});
}

void key(String keysym, int repeat) {
	println("key " + keysym + " " + repeat);
	while(repeat > 0) {
		execSync(new String[] {"xdotool", "key", keysym});
		repeat--;
	}
}

void key(String keysym) {
	key(keysym, 1);
}

void type(String s) {
	execSync(new String[] {"xdotool", "type", s});
}
