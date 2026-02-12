import from uuid { uuid4 }
import from byllm.lib { Model }

cl import "./styles.css";

glob llm = Model(model_name="ollama/llama3.2:1b");

node Todo {
    has id: str,
        title: str,
        done: bool = False,
        category: str = "other",
        memory: str = "";
}

# ---- AI categorizer (string based, no enum) ----
def categorize(title: str) -> str by llm(
    system_prompt="You are a classifier. Return ONLY one word: work, shopping, health, personal, or other."
);

def summarize(text: str) -> str by llm(
    system_prompt="Summarize this todo into one short helpful memory sentence."
);

"""Add todo"""
def:pub add_todo(title: str) -> dict {
    raw = categorize(title).lower();

    category =
        "work" if "work" in raw else
        "shopping" if "shop" in raw or "buy" in raw else
        "health" if "health" in raw or "gym" in raw else
        "personal" if "personal" in raw else
        "other";

    todo = root ++> Todo(
        id=str(uuid4()),
        title=title,
        category=category,
        memory=""
    );

    return {
        "id": todo[0].id,
        "title": todo[0].title,
        "done": todo[0].done,
        "category": todo[0].category,
        "memory": todo[0].memory
    };
}
"""Generate AI memory for a todo"""
def:pub remember_todo(id: str) -> dict {
    for todo in [root-->](?:Todo) {
        if todo.id == id {
            todo.memory = summarize(todo.title);
            return {
                "id": todo.id,
                "memory": todo.memory
            };
        }
    }
    return {};
}

"""Get todos"""
def:pub get_todos -> list {
    return [
        {
            "id": t.id,
            "title": t.title,
            "done": t.done,
            "category": t.category,
            "memory": t.memory
        }
        for t in [root-->](?:Todo)
    ];
}

"""Toggle"""
def:pub toggle_todo(id: str) -> dict {
    for t in [root-->](?:Todo) {
        if t.id == id {
            t.done = not t.done;
            return {
                "id": t.id,
                "title": t.title,
                "done": t.done,
                "category": t.category,
                "memory": t.memory
            };
        }
    }
    return {};
}

"""Delete"""
def:pub delete_todo(id: str) -> dict {
    for t in [root-->](?:Todo) {
        if t.id == id {
            del t;
            return {"deleted": id};
        }
    }
    return {};
}

# ---------------- CLIENT ----------------

cl def:pub app -> any {
    has items: list = [],
        text: str = "";

    async can with entry {
        items = await get_todos();
    }

    async def add -> None {
        if text.trim() {
            todo = await add_todo(text.trim());
            items = items.concat([todo]);
            text = "";
        }
    }

    async def toggle(id: str) -> None {
        await toggle_todo(id);
        items = items.map(
            lambda t: any -> any {
                return {
                    "id": t.id,
                    "title": t.title,
                    "done": not t.done,
                    "category": t.category,
                    "memory": t.memory
                }
                if t.id == id else t;
            }
        );
    }

    async def remove(id: str) -> None {
        await delete_todo(id);
        items = items.filter(lambda t: any -> bool { return t.id != id; });
    }

    # ✅ NEW: remember button calls server remember_todo()
    async def remember(id: str) -> None {
        res = await remember_todo(id);
        items = items.map(
            lambda t: any -> any {
                return {
                    "id": t.id,
                    "title": t.title,
                    "done": t.done,
                    "category": t.category,
                    "memory": res.memory
                }
                if t.id == id else t;
            }
        );
    }

    remaining = items.filter(lambda t: any -> bool { return not t.done; }).length;

    return
        <div class="container">
            <h1>Todo App</h1>

            <div class="input-row">
                <input
                    class="input"
                    value={text}
                    onChange={lambda e: any -> None { text = e.target.value; }}
                    onKeyPress={lambda e: any -> None {
                        if e.key == "Enter" { add(); }
                    }}
                    placeholder="What needs to be done?"
                />
                <button class="btn-add" onClick={add}>Add</button>
            </div>

            {[
                <div key={t.id} class="todo-item">
                    <input
                        type="checkbox"
                        checked={t.done}
                        onChange={lambda -> None { toggle(t.id); }}
                    />

                    <div class="todo-main">
                        <div class={"todo-title " + ("todo-done" if t.done else "")}>
                            {t.title}
                        </div>

                        {(
                            <div class="memory-text">
                                🧠 {t.memory}
                            </div>
                        ) if t.memory else None}
                    </div>

                    <span class="category">{t.category}</span>

                    <button class="btn-memory"
                        onClick={lambda -> None { remember(t.id); }}>
                        🧠
                    </button>

                    <button class="btn-delete"
                        onClick={lambda -> None { remove(t.id); }}>
                        X
                    </button>
                </div>
                for t in items
            ]}

            <div class="count">{remaining} items remaining</div>
        </div>;
}