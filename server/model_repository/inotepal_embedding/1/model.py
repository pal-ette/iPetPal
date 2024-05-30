import json
import triton_python_backend_utils as pb_utils

try:
    from sentence_transformers import SentenceTransformer
except ModuleNotFoundError:
    import subprocess
    import sys

    def install(package):
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])

    install("sentence_transformers")
    from sentence_transformers import SentenceTransformer


class TritonPythonModel:

    def initialize(self, args):
        self.model_config = json.loads(args["model_config"])

        output0_config = pb_utils.get_output_config_by_name(
            self.model_config, "OUTPUT0"
        )

        self.output0_dtype = pb_utils.triton_string_to_numpy(
            output0_config["data_type"]
        )

        self.model = SentenceTransformer("jhgan/ko-sroberta-multitask")

    def _process_request(self, request):
        in_0 = pb_utils.get_input_tensor_by_name(request, "INPUT0")

        out_0 = self.model.encode(in_0.as_numpy()[0].decode("utf-8"))

        return pb_utils.InferenceResponse(
            output_tensors=[
                pb_utils.Tensor("OUTPUT0", out_0.astype(self.output0_dtype)),
            ]
        )

    def execute(self, requests):
        return [self._process_request(request) for request in requests]
