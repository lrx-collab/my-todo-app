"""Client implementations.""";

impl app.fetchTodos -> None {
    loading = True;
    res = root spawn ListTodos();
    todos = res.reports[0] if res.reports else [];
    loading = False;
}

impl app.addTodo -> None {
    if not text.trim() { return; }
    res = root spawn AddTodo(title=text.trim());
    if res.reports and res.reports.length > 0 {
        todos = todos.concat([res.reports[0]]);
    }
    text = "";
}

impl app.toggleTodo(id: str) -> None {
    root spawn ToggleTodo(todo_id=id);
    todos = todos.map(
        lambda t: any -> any {
            if t.id == id {
                return {
                    "id": t.id,
                    "title": t.title,
                    "completed": not t.completed,
                    "allergens": t.allergens,
                    "trace_risk": t.trace_risk,
                    "verdict": t.verdict
                };
            }
            return t;
        }
    );
}

impl app.deleteTodo(id: str) -> None {
    root spawn DeleteTodo(todo_id=id);
    todos = todos.filter(lambda t: any -> bool { return t.id != id; });
}