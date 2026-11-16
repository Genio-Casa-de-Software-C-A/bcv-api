// @ts-types="npm:@types/express@latest"
import express from "express";
import { Currency, getCurrencyFromBCV } from "jsr:@quikiesamus/scrape-bcv";

const app = express();
const PORT = (Deno.env.get("PORT")) || 3000;

/**
 * This is the representation of the response made by the server
 */
type CurrencyResponse = {
  [currency: string]: number;
};

async function getCurrencies(): Promise<CurrencyResponse> {
  const entries = Object.entries(Currency);
  const results = await Promise.all(
    entries.map(async ([code, selector]) => {
      const value = await getCurrencyFromBCV(selector);
      return [code, value] as const;
    }),
  );
  return Object.fromEntries(results);
}

app.get("/currencies", async (_req, res) => {
  try {
    const response = await getCurrencies();
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch currencies", details: String(error) });
  }
});

app.get("/currencies/:name", (req, res) => {
  const name: keyof typeof Currency = req.params.name as keyof typeof Currency;
  const response: CurrencyResponse = {};
  getCurrencyFromBCV(Currency[name]).then((currencyValue) => {
    response[name] = currencyValue;
    res.json(response);
  }).catch((err) => {
    res.type("text");
    res.status(404).send(`${name} not found. ${err.toString()}`);
    res.end();
  });
});

app.get("/health", async (_req, res) => {
  try {
    await getCurrencies();
    res.send("Ok");
  } catch (error) {
    res.status(500).send(`Api failed fetching one of the values: ${error}`);
  }
});

app.all("{*splat}", (_req, res) => {
  res.type("text");
  res.status(404).send("not found");
  res.end();
});

app.listen(PORT, () => console.log(`Server running on PORT ${PORT}`));
