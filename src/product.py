#!/usr/bin/env python
import json

import psycopg2
import requests
from psycopg2.extras import Json

BASE = {
    "CBA": "https://api.commbank.com.au",
    "WPC": "https://digital-api.westpac.com.au",
    "ANZ": "https://api.anz",
}


class API:
    URL_PREFIX = "cds-au"
    VERSION = "v1"

    def __init__(self, bank):
        self.bank = bank

    def join_url(self, endpoint, *args):
        """concatenates the url endpoint and arguments
        """
        return "/".join(
            [BASE[self.bank], self.URL_PREFIX, self.VERSION, endpoint] + list(args)
        )

    def get_request(self, url):
        """sends a get request and returns json if valid response
        """
        params = {"page-size": 1000}
        headers = {"x-v": "1"}

        r = requests.get(url, params=params, headers=headers)
        if r.status_code == 200:
            return r.json()

    def get_products(self):
        """https://consumerdatastandardsaustralia.github.io/standards/#get-products
        """
        url = self.join_url("banking/products")
        return self.get_request(url)

    def get_product_detail(self, product_id):
        """https://consumerdatastandardsaustralia.github.io/standards/#get-product-detail
        """
        url = self.join_url("banking/products", product_id)
        return self.get_request(url)

    def download_products(self):
        """downloads all products available for bank
        """
        products = self.get_products()

        conn = psycopg2.connect("dbname=open_banking")
        cur = conn.cursor()

        for product in products["data"]["products"]:
            product_id = product["productId"]
            product_detail_results = self.get_product_detail(product_id)

            # TODO: only insert updated records
            cur.execute(
                "insert into raw.products (jsondata) values (%s)",
                [Json(product_detail_results)],
            )
            # with open(f"./data/products/{self.bank}-{product_id}.json", "w") as f:
            #     json.dump(product_detail_results, f)

        conn.commit()
        cur.close()
        conn.close()


if __name__ == "__main__":
    for bank in BASE:
        api = API(bank)
        api.download_products()
