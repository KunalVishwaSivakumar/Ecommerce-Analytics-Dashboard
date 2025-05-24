import pandas as pd
import mysql.connector

def insert_all_into_mysql(df, host, user, password, database):
    conn = mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=database
    )
    cursor = conn.cursor()

    # 1. Insert category
    categories = df['category'].dropna().unique()
    cursor.executemany("INSERT IGNORE INTO category (category_name) VALUES (%s);", [(cat,) for cat in categories])

    # 2. Insert product
    for _, row in df[['product_id', 'product_name', 'category']].drop_duplicates().iterrows():
        cursor.execute("SELECT category_id FROM category WHERE category_name = %s;", (row['category'],))
        category_id = cursor.fetchone()[0]
        cursor.execute(
            "INSERT IGNORE INTO product (product_id, product_name, category_id) VALUES (%s, %s, %s);",
            (row['product_id'], row['product_name'], category_id)
        )

    # 3. Insert customer
    customer_cols = ['customer_id', 'customer_age', 'customer_gender', 'customer_income', 'customer_loyalty_level']
    customers = df[customer_cols].drop_duplicates()
    cursor.executemany(
        "INSERT IGNORE INTO customer (customer_id, customer_age, customer_gender, customer_income, customer_loyalty_level) VALUES (%s, %s, %s, %s, %s);",
        [tuple(row) for _, row in customers.iterrows()]
    )

    # 4. Insert store_location
    store_locations = df['store_location'].dropna().unique()
    cursor.executemany("INSERT IGNORE INTO store_location (store_location) VALUES (%s);", [(loc,) for loc in store_locations])

    # 5. Insert store and store_location_map
    for _, row in df[['store_id', 'store_location']].drop_duplicates().iterrows():
        cursor.execute("INSERT IGNORE INTO store (store_id) VALUES (%s);", (row['store_id'],))
        cursor.execute("SELECT store_location_id FROM store_location WHERE store_location = %s;", (row['store_location'],))
        loc_id = cursor.fetchone()[0]
        cursor.execute(
            "INSERT IGNORE INTO store_location_map (store_id, store_location_id) VALUES (%s, %s);",
            (row['store_id'], loc_id)
        )

    # 6. Insert supplier
    suppliers = df['supplier_id'].dropna().unique()
    cursor.executemany("INSERT IGNORE INTO supplier (supplier_id) VALUES (%s);", [(int(sid),) for sid in suppliers])

    # 7. Insert product_supplier_map
    for _, row in df[['product_id', 'supplier_id', 'supplier_lead_time']].drop_duplicates().iterrows():
        cursor.execute(
            "INSERT IGNORE INTO product_supplier_map (product_id, supplier_id, supplier_lead_time) VALUES (%s, %s, %s);",
            (int(row['product_id']), int(row['supplier_id']), int(row['supplier_lead_time']))
        )

    # 8. Insert payment_method
    methods = df['payment_method'].dropna().unique()
    cursor.executemany("INSERT IGNORE INTO payment_method (method_name) VALUES (%s);", [(m,) for m in methods])


    # 9. Insert promotion
    for _, row in df[['promotion_type', 'promotion_applied']].drop_duplicates().iterrows():
        promo_type = row['promotion_type']
        if pd.isna(promo_type) or str(promo_type).strip().lower() == 'none':
            promo_type = 'No Promotion'

        promo_applied = int(row['promotion_applied']) if not pd.isna(row['promotion_applied']) else False
        cursor.execute(
            "INSERT IGNORE INTO promotion (promotion_type, promotion_applied) VALUES (%s, %s);",
            (promo_type, promo_applied)
        )

    # 10. Insert weather
    weather_conditions = df['weather_conditions'].dropna().unique()
    cursor.executemany("INSERT IGNORE INTO weather (weather_conditions) VALUES (%s);", [(w,) for w in weather_conditions])

    # 11. Insert product_store_inventory_map
    for _, row in df[['product_id', 'store_id', 'inventory_level', 'reorder_point', 'reorder_quantity']].drop_duplicates().iterrows():
        cursor.execute(
            "INSERT IGNORE INTO product_store_inventory_map (product_id, store_id, inventory_level, reorder_point, reorder_quantity) VALUES (%s, %s, %s, %s, %s);",
            (
                int(row['product_id']) if pd.notna(row['product_id']) else None,
                int(row['store_id']) if pd.notna(row['store_id']) else None,
                int(row['inventory_level']) if pd.notna(row['inventory_level']) else None,
                int(row['reorder_point']) if pd.notna(row['reorder_point']) else None,
                int(row['reorder_quantity']) if pd.notna(row['reorder_quantity']) else None
            )
        )

    # 12. Insert transaction (with store_location_id lookup from bridge)
    for _, row in df.iterrows():
        # Payment method FK
        cursor.execute("SELECT payment_method_id FROM payment_method WHERE method_name = %s;", (row['payment_method'],))
        payment_result = cursor.fetchone()
        payment_id = payment_result[0] if payment_result else None

        # Promotion FK
        # Promotion FK
        promo_type = row['promotion_type']
        if pd.isna(promo_type) or promo_type == 'None':
            promo_type = 'No Promotion'

        promo_applied = int(row['promotion_applied']) if not pd.isna(row['promotion_applied']) else 0

        promotion_id = None
        cursor.execute("SELECT promotion_id FROM promotion WHERE promotion_type = %s AND promotion_applied = %s;",
                       (promo_type, promo_applied))
        promo_result = cursor.fetchone()
        promotion_id = promo_result[0] if promo_result else None

        # Weather FK
        cursor.execute("SELECT weather_id FROM weather WHERE weather_conditions = %s;", (row['weather_conditions'],))
        weather_result = cursor.fetchone()
        weather_id = weather_result[0] if weather_result else None

        # ✅ Store Location ID (NEW ADDITION)
        cursor.execute("""
            SELECT sl.store_location_id
            FROM store_location_map slm
            JOIN store_location sl ON slm.store_location_id = sl.store_location_id
            WHERE slm.store_id = %s AND sl.store_location = %s
            LIMIT 1;
        """, (row['store_id'], row['store_location']))
        location_result = cursor.fetchone()
        store_location_id = location_result[0] if location_result else None

        # Final insert
        cursor.execute("""
            INSERT IGNORE INTO transaction (
                transaction_id, customer_id, product_id, store_id, store_location_id,
                transaction_date, quantity_sold, unit_price,
                payment_method_id, promotion_id, weather_id,
                holiday_indicator, weekday,
                forecasted_demand, actual_demand, stockout_indicator
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        """, (
            row['transaction_id'], row['customer_id'], row['product_id'], row['store_id'], store_location_id,
            row['transaction_date'], row['quantity_sold'], row['unit_price'],
            payment_id, promotion_id, weather_id,
            bool(row['holiday_indicator']), row['weekday'],
            row['forecasted_demand'], row['actual_demand'], bool(row['stockout_indicator'])
        ))

    conn.commit()
    cursor.close()
    conn.close()
    return "✅ All data inserted successfully into MySQL."


# Load and normalize
df = pd.read_csv("Walmart_final_customer_updated.csv")
df.columns = df.columns.str.strip().str.lower()

# Run insert
insert_all_into_mysql(df, host="localhost", user="root", password="Kunal@123", database="ecommerce_project")
