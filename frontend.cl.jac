"""Client UI (v0.10 style)."""

cl import "./styles.css"
cl import from .components.TodoItem { TodoItem }

sv import from main { AddTodo, ListTodos, ToggleTodo, DeleteTodo };

cl def:pub app -> any {
    has todos: list = [],
        text: str = "",
        loading: bool = True;

    can with entry {
        fetchTodos();
    }

    async def fetchTodos -> None;
    async def addTodo -> None;
    async def toggleTodo(id: str) -> None;
    async def deleteTodo(id: str) -> None;

    return
        <div className="container">
            <h1>VeroEat Safety Todo</h1>

            <div className="input-row">
                <input
                    className="input"
                    value={text}
                    onChange={lambda e: any -> None { text = e.target.value; }}
                    onKeyPress={lambda e: any -> None {
                        if e.key == "Enter" { addTodo(); }
                    }}
                    placeholder="Enter food item..."
                />
                <button className="btn btn-add" onClick={addTodo}>Add</button>
            </div>

            {(
                <div className="loading">Loading...</div>
            ) if loading else None}

            {[
                TodoItem(todo=t, onToggle=toggleTodo, onDelete=deleteTodo)
                for t in todos
            ]}

            <div className="count">{len(todos)} items</div>
        </div>;
}