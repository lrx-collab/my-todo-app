"""Todo item component.""";

def:pub TodoItem(todo: dict, onToggle: any, onDelete: any) -> any {
    return
        <div className="todo-item">
            <input
                type="checkbox"
                checked={todo.completed}
                onChange={lambda -> None { onToggle(todo.id); }}
            />

            <div className="todo-main">
                <div className={"todo-title " + ("todo-done" if todo.completed else "")}>
                    {todo.title}
                </div>

                <div className="meta-row">
                    <span className={"verdict " + todo.verdict}>{todo.verdict}</span>

                    {[
                        <span key={a} className="allergen">{a}</span>
                        for a in (todo.allergens if todo.allergens else [])
                    ]}

                    {(
                        <span className="trace">⚠ may contain traces</span>
                    ) if todo.trace_risk else None}
                </div>
            </div>

            <button className="btn btn-delete" onClick={lambda -> None { onDelete(todo.id); }}>
                X
            </button>
        </div>;
}