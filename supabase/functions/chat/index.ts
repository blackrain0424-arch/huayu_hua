// Supabase Edge Function: AI chat + vision proxy
// Deploy with: supabase functions deploy chat
// Set secrets: supabase secrets set DEEPSEEK_KEY=sk-xxx VISION_KEY=sk-xxx

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const DEEPSEEK_KEY = Deno.env.get("DEEPSEEK_KEY") ?? "";
const DEEPSEEK_URL = "https://api.deepseek.com/v1/chat/completions";

const VISION_KEY = Deno.env.get("VISION_KEY") ?? "";
const VISION_URL =
  "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";
const VISION_MODEL = "qwen-vl-plus";

const corsHeaders = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const { messages, hasImage, userText } = body;

    if (!messages || !Array.isArray(messages)) {
      return new Response(
        JSON.stringify({ error: "Missing messages array" }),
        { status: 400, headers: corsHeaders },
      );
    }

    let apiUrl: string;
    let apiKey: string;
    let model: string;
    let apiMessages: any[];

    if (hasImage && VISION_KEY) {
      // Use vision API for image recognition
      apiUrl = VISION_URL;
      apiKey = VISION_KEY;
      model = VISION_MODEL;
      apiMessages = [
        {
          role: "system",
          content:
            "你是一个专业的花卉识别助手。识别图片中的花卉，给出花名、分布范围、观赏季节和花语。中文回复，300字以内。",
        },
      ];

      // Build user message with image
      const lastMsg = messages[messages.length - 1];
      apiMessages.push(lastMsg);
    } else if (DEEPSEEK_KEY) {
      // Use DeepSeek for text chat
      apiUrl = DEEPSEEK_URL;
      apiKey = DEEPSEEK_KEY;
      model = "deepseek-chat";
      apiMessages = [
        {
          role: "system",
          content:
            "你是花语Bot🌸，一个专业的花卉助手。回复用中文，温暖简洁，300字以内，以花相关emoji开头。",
        },
        ...messages.filter((m: any) => m.role !== "system"),
      ];
    } else {
      return new Response(
        JSON.stringify({ error: "No API key configured" }),
        { status: 500, headers: corsHeaders },
      );
    }

    const response = await fetch(apiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model,
        messages: apiMessages,
        max_tokens: 600,
        temperature: 0.7,
      }),
    });

    if (!response.ok) {
      const errText = await response.text();
      return new Response(
        JSON.stringify({
          error: `AI API error (${response.status})`,
          detail: errText.substring(0, 300),
        }),
        { status: 502, headers: corsHeaders },
      );
    }

    const data = await response.json();
    const content =
      data?.choices?.[0]?.message?.content ?? "AI 返回了空回复";

    return new Response(JSON.stringify({ content }), {
      headers: corsHeaders,
    });
  } catch (e) {
    return new Response(
      JSON.stringify({ error: "Internal error", detail: String(e) }),
      { status: 500, headers: corsHeaders },
    );
  }
});
