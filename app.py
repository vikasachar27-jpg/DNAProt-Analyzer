import sys
from unittest.mock import MagicMock

# 1. BYPASS DEPENDENCY ERRORS
# This prevents the 'HfFolder' ImportError common in some cloud environments
sys.modules["gradio.oauth"] = MagicMock()

import gradio as gr
import subprocess
import os

# 2. ANALYSIS LOGIC
def analyze_sequence(file_obj):
    if file_obj is None:
        return "⚠️ Please upload a FASTA file."

    # Path to your custom shell script
    script_path = "./DNAProt.sh"

    try:
        # EXECUTION: Running the Bash script through the Linux environment
        result = subprocess.run(
            ['bash', script_path, file_obj.name], 
            capture_output=True, 
            text=True
        )

        # Error handling if the script fails
        if result.stderr:
            return f"❌ Script Error:\n{result.stderr}"

        return result.stdout

    except Exception as e:
        return f"❌ System Error: {str(e)}"

# 3. GRADIO FRONTEND UI
# NOTE: In Gradio 6.0, 'theme' is no longer passed here. 
with gr.Blocks() as demo:
    gr.HTML("""
        <div style="text-align: center; padding: 20px; background: linear-gradient(90deg, #1e3a8a, #3b82f6); border-radius: 10px; color: white;">
            <h1 style="margin: 0;">🧬 DNAProt Pro Analyzer</h1>
            <p style="margin: 5px 0 0 0;">Advanced Genomic Analytics Dashboard | By Adisri Menon , Dhanush R M ,Vikas K R</p>
        </div>
    """)

    gr.Markdown("### 🛠️ Upload Sequence")
    with gr.Row():
        with gr.Column(scale=1):
            file_input = gr.File(label="Upload .fasta / .txt")
            submit_btn = gr.Button("🚀 Run Full Analysis", variant="primary")

        with gr.Column(scale=2):
            output_text = gr.Textbox(
                label="Analysis Report", 
                lines=20, 
                placeholder="Results will appear here..."
            )

    # Link the button to the function
    submit_btn.click(fn=analyze_sequence, inputs=file_input, outputs=output_text)

# 4. RENDER DEPLOYMENT SETTINGS
if __name__ == "__main__":
    # Render provides a dynamic port via environment variables.
    port = int(os.environ.get("PORT", 10000))

    demo.launch(
        server_name="0.0.0.0", 
        server_port=port, 
        share=False,
        theme=gr.themes.Soft(), # ✅ Theme is now passed here in Gradio 6.0
        # show_api has been removed in Gradio 6.0 to prevent internal errors
    )