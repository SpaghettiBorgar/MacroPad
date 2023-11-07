void storePages() {
	JSONObject json = new JSONObject();
	JSONArray jpages = new JSONArray();

	for(int p = 0; p < actions.numPages(); p++) {
		Action page[][] = actions.pages.get(p);
		JSONObject jpage = new JSONObject();
		JSONArray jrows = new JSONArray();

		for(int j = 0; j < PAGESIZE; j++) {
			JSONArray jrow = new JSONArray();

			for(int i = 0; i < PAGESIZE; i++) {
				Action action = page[j][i];
				JSONObject jbutton = action.serializeJSON();

				jbutton.setString("type", action.getClass().getSimpleName());

				jrow.append(jbutton);
			}
			jrows.append(jrow);
		}
		jpage.setJSONArray("buttons", jrows);
		jpage.setString("name", actions.pageNames.get(p));
		jpages.append(jpage);
	}
	json.setJSONArray("pages", jpages);

	saveJSONObject(json, "data.json");
}

void restorePages() {
	JSONObject json = loadJSONObject("data.json");
	JSONArray jpages = json.getJSONArray("pages");

	for (int p = 0; p < jpages.size(); p++) {
		JSONObject jpage = jpages.getJSONObject(p);
		JSONArray jrows = jpage.getJSONArray("buttons");
		for (int j = 0; j < jrows.size(); j++) {
			JSONArray jrow = jrows.getJSONArray(j);
			for (int i = 0; i < jrow.size(); i++) {
				JSONObject jbutton = jrow.getJSONObject(i);

				try {
					String actionType = jbutton.getString("type");
					Action action;
					action = ((Action) Class.forName(getClass().getName() + "$" + actionType).getConstructor(getClass()).newInstance(this));
					action.deserializeJSON(jbutton);
					actions.addAction(p, j, i, action);
				} catch(Exception e) {
					e.printStackTrace();
				}
			}
		}
		actions.pageNames.set(p, jpage.getString("name"));
	}
}
