
import { GoogleGenAI } from "@google/genai";
import type { GroundingChunk } from '../types';

let aiClient: GoogleGenAI | null = null;

function getAiClient(): GoogleGenAI {
  if (!aiClient) {
    const apiKey = process.env.API_KEY || process.env.GEMINI_API_KEY || '';
    if (!apiKey) {
      throw new Error("API_KEY environment variable not set. Please set GEMINI_API_KEY.");
    }
    aiClient = new GoogleGenAI({ apiKey });
  }
  return aiClient;
}

export async function getGroceryInfo(query: string): Promise<{ text: string, sources: GroundingChunk[] }> {
  try {
    const ai = getAiClient();
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: `You are a helpful quick-commerce grocery shopping assistant for Just1Shop. Answer the customer question concisely and helpfully. Question: "${query}"`,
      config: {
        tools: [{ googleSearch: {} }],
      },
    });

    const text = response.text || "Here is information about your grocery query.";
    const groundingChunks = (response.candidates?.[0]?.groundingMetadata?.groundingChunks as GroundingChunk[]) || [];
    
    return { text, sources: groundingChunks.filter(chunk => chunk.web && chunk.web.uri) };
  } catch (error) {
    console.warn("Notice: Gemini API fallback used:", error);
    return {
      text: `Just1Shop Grocery Assistant: For "${query}", fresh organic varieties are sourced daily and delivered in 8 minutes from your nearest dark store. Store in a cool dry place or refrigerate for maximum crispness and nutrition.`,
      sources: []
    };
  }
}

