"""HTTP-сервер калькулятора: /calc и /ready."""

import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

from app.delivery import delivery_price


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        url = urlparse(self.path)
        if url.path == "/ready":
            self._send(200, {"status": "ok"})
            return
        if url.path == "/calc":
            q = parse_qs(url.query)
            try:
                price = delivery_price(
                    q["city"][0], int(q["sum"][0]), q.get("express", ["0"])[0] == "1"
                )
            except (KeyError, ValueError) as e:
                self._send(400, {"code": "bad_request", "message": str(e)})
                return
            self._send(200, {"price": price})
            return
        self._send(404, {"code": "not_found", "message": url.path})

    def _send(self, code, body):
        data = json.dumps(body, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(data)


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
