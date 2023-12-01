import os
import json

import click
import requests

API_ENDPOINT = os.environ["API_ENDPOINT"]
API_KEY = os.environ["API_KEY"]

HEADERS = {
    'Content-Type': "application/json",
    'x-api-key': API_KEY
}

URL = f"https://{API_ENDPOINT}"


@click.group
def cli():
    """Base method for the cli"""


@click.command()
@click.option('-x', help="HTTP Method to call the api")
@click.option('-path', help="The path to request")
@click.option('-body', default="", help="Body for the POST and PUT requests")
def query(x, path, body):
    """Invoke the API gateway"""

    full_url = os.path.join(URL, path)
    click.echo(f"Invoking: {x.upper()} {full_url}")
    res: requests.Response = getattr(requests, x.lower())(
        full_url,
        headers=HEADERS,
        timeout=10,
        json=json.loads(body) if body != "" else None
    )
    res.raise_for_status()

    click.echo("--------------------------------------------------------")
    click.echo(f"- Status Code: {res.status_code}")
    click.echo(f"- Response:    {res.json()}")
    click.echo("--------------------------------------------------------")


cli.add_command(query)

if __name__ == "__main__":
    cli()
