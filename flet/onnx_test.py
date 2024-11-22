import onnxruntime
import flet as ft


def main(page: ft.Page):
    page.title = "Flet counter example"
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    model_input_name_text = ft.Text("")

    def on_click_button(e):
        filepath = './eye_binary.onnx'
        ort_session = onnxruntime.InferenceSession(filepath)
        model_input_name_text.value = ort_session.get_inputs()[0].name
        page.update()

    page.add(
        ft.Row(
            [
                ft.IconButton(ft.icons.THEATER_COMEDY, on_click=on_click_button),
                model_input_name_text,
            ],
            alignment=ft.MainAxisAlignment.CENTER,
        )
    )

ft.app(main)
