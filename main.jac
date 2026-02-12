"""VeroEat Safety Todo (Single-file, Part-2 style)."""

import from uuid { uuid4 }
import from byllm.lib { Model }

cl import "./styles.css";

glob llm = Model(model_name="ollama/llama3.2:1b");

# ---------------- DATA ----------------

node FoodTodo {
    has id: str,
        title: str,
        done: bool = False,

        # VeroEat-like safety fields
        allergens: list[str] = [],
        trace_risk: bool = False,
        verdict: str = "unknown";   # safe | caution | avoid | unknown
}

# Structured AI output
obj SafetyResult {
    has allergens: list[str];
    has trace_risk: bool;
    has verdict: str;
}

# AI: analyze a food item / ingredient / menu line
def analyze_food(text: str) -> SafetyResult by llm(
    system_prompt=
        "You are a food safety classifier. "
        "Return ONLY a structured object with fields: "
        "allergens: list of lowercase strings chosen from [milk, egg, peanut, tree nut, soy, wheat, fish, shellfish, sesame]; "
        "trace_risk: boolean true if it says may contain traces / processed in a facility / cross-contamination risk; "
        "verdict: one of [safe, caution, avoid, unknown]. "
        "If unclear, set verdict='unknown'. "
        "Do NOT add extra fields. Do NOT add explanations."
);

# ---------------- SERVER API (Part 2 style) ----------------

"""Add a todo with AI safety analysis."""
def:pub add_todo(title: str) -> dict {
    r = analyze_food(title);

    todo = root ++> FoodTodo(
        id=str(uuid4()),
        title=title,
        allergens=r.allergens,
        trace_risk=r.trace_risk,
        verdict=r.verdict
    );

    return {
        "id": todo[0].id,
        "title": todo[0].title,
        "done": todo[0].done,
        "allergens": todo[0].allergens,
        "trace_risk": todo[0].trace_risk,
        "verdict": todo[0].verdict
    };
}

"""Get all todos."""
def:pub get_todos -> list {
    return [
        {
            "id": t.id,
            "title": t.title,
            "done": t.done,
            "allergens": t.allergens,
            "trace_risk": t.trace_risk,
            "verdict": t.verdict
        }
        for t in [root-->](?:FoodTodo)
    ];
}

"""Toggle done."""
def:pub toggle_todo(id: str) -> dict {
    for t in [root-->](?:FoodTodo) {
        if t.id == id {
            t.done = not t.done;
            return {
                "id": t.id,
                "title": t.title,
                "done": t.done,
                "allergens": t.allergens,
                "trace_risk": t.trace_risk,
                "verdict": t.verdict
            };
        }
    }
    return {};
}

"""Delete."""
def:pub delete_todo(id: str) -> dict {
    for t in [root-->](?:FoodTodo) {
        if t.id == id {
            del t;
            return {"deleted": id};
        }
    }
    return {};
}

# ---------------- CLIENT UI ----------------

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
                    "allergens": t.allergens,
                    "trace_risk": t.trace_risk,
                    "verdict": t.verdict
                }
                if t.id == id else t;
            }
        );
    }

    async def remove(id: str) -> None {
        await delete_todo(id);
        items = items.filter(lambda t: any -> bool { return t.id != id; });
    }

    remaining = items.filter(lambda t: any -> bool { return not t.done; }).length;

    # helper for badge class
    def verdictClass(v: str) -> str {
        return
            "badge safe" if v == "safe" else
            "badge caution" if v == "caution" else
            "badge avoid" if v == "avoid" else
            "badge unknown";
    }

    return
        <div class="container">
            <h1>VeroEat Safety Todo</h1>
            <p class="subtitle">Type a food/ingredient. AI normalizes allergens + trace risk + verdict (Ollama).</p>

            <div class="input-row">
                <input
                    class="input"
                    value={text}
                    onChange={lambda e: any -> None { text = e.target.value; }}
                    onKeyPress={lambda e: any -> None {
                        if e.key == "Enter" { add(); }
                    }}
                    placeholder="e.g., 'Chocolate chip cookie (may contain nuts)'"
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

                        <div class="meta">
                            <span class={verdictClass(t.verdict)}>
                                {t.verdict}
                            </span>

                            {(
                                <span class="trace">⚠ may contain / trace risk</span>
                            ) if t.trace_risk else None}

                            {[
                                <span key={a} class="allergen">{a}</span>
                                for a in (t.allergens if t.allergens else [])
                            ]}
                        </div>
                    </div>

                    <button class="btn-delete" onClick={lambda -> None { remove(t.id); }}>
                        X
                    </button>
                </div>
                for t in items
            ]}

            <div class="count">{remaining} items remaining</div>
        </div>;
}