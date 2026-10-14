import json
import os
import string
import typing
from urllib.parse import quote

import requests
from bs4 import BeautifulSoup

ROOT = os.path.dirname(__file__)
CACHE = os.path.join(ROOT, "caches")
ASSETS = os.path.join(os.path.dirname(ROOT), "assets")

os.makedirs(CACHE, exist_ok=True)
os.makedirs(ASSETS, exist_ok=True)

with open(os.path.join(ROOT, "guas.json"), encoding="utf8") as f:
    guas: dict[str, str] = json.load(f)


def fetch_gua_html(name: str):
    url = f"https://zh.wikisource.org/zh-hant/%E5%91%A8%E6%98%93/{quote(name)}"
    resp = requests.get(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36"
        },
    )
    resp.raise_for_status()
    with open(os.path.join(CACHE, f"{name}.html"), "wb+") as cf:
        cf.write(resp.content)


def open_html(name: str, retry_times: int = 0) -> str:
    try:
        with open(os.path.join(CACHE, f"{name}.html"), encoding="utf8") as f:
            return f.read()
    except OSError:
        fetch_gua_html(name)
        rt = retry_times + 1
        if rt > 5:
            raise
        return open_html(name, retry_times=rt)


def _remove_all_small(node: typing.Any):
    for e in node.find_all("small"):
        e.decompose()


def _one_line(v: str):
    return v.translate(str.maketrans("", "", string.whitespace))


class GuaInfo(typing.TypedDict):
    name: str
    ci: str
    yaos: list[str]


ALL_GUA_INFOS: dict[str, GuaInfo] = {}


for binary, name in guas.items():
    html = open_html(name)
    soup = BeautifulSoup(html, "lxml")

    yijing = soup.find("b", string="易經：").parent.parent.parent  # type: ignore
    assert yijing is not None
    # tuan = yijing.find_next_sibling()
    # assert tuan is not None
    # xiang = tuan.find_next_sibling()

    _remove_all_small(yijing)
    # _remove_all_small(tuan)
    # _remove_all_small(xiang)

    ci_ul = yijing.find("ul")
    assert ci_ul is not None
    ci_ul_text = ci_ul.get_text()
    ci = _one_line(ci_ul_text[len(name) + 1 :].strip())
    # print(name, ci)

    yaos_ol = yijing.find("ol").find_all("li")  # type: ignore
    # print(yaos_ol)

    yao_lst: list[str] = []
    for li in yaos_ol:
        txt = li.get_text().strip()
        yao_lst.append(_one_line(txt))

    # print(name, yao_lst)

    ALL_GUA_INFOS[binary] = {"name": name, "ci": ci, "yaos": yao_lst}

with open(os.path.join(ASSETS, "guas.json"), "w+", encoding="utf8") as f:
    json.dump(ALL_GUA_INFOS, f, ensure_ascii=False, indent=2, sort_keys=True)
