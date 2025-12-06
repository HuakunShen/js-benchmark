import { Hono } from "hono";
const app = new Hono();

app
  .get("/", (c) => c.text("Hono!"))
  .get("/json", (c) => {
    // Generate a long and complex nested JSON object
    const complexJson: any = { root: {} };

    let currentLevel = complexJson.root;
    for (let i = 0; i < 10; i++) {
      currentLevel[`level_${i}`] = {
        message: `This is level ${i}`,
        value: i * 10,
        nested: {},
        items: Array.from({ length: 5 }, (_, j) => ({
          id: `${i}-${j}`,
          detail: `Item ${j} at level ${i}`,
          stuff: {
            even: j % 2 === 0,
            props: Array.from({ length: 2 }, (_, k) => ({
              propKey: `level${i}_item${j}_prop${k}`,
              propVal: Math.random(),
            })),
          },
        })),
      };
      // Create additional nesting
      currentLevel = currentLevel[`level_${i}`].nested;
    }
    return c.json(complexJson);
  });

export default app;
