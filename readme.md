# Lenskart Retail Management Database

This project contains a fully normalized MySQL database schema designed for an eyewear retail ecosystem similar to **Lenskart**. It models customer journeys end-to-end — from eye-test appointments to purchasing frames and lenses, inventory management, supplier procurement, and payments.

---

## 📌 Project Overview

The database captures real-world operational flows of an optical retail chain:

- Customer onboarding and address management  
- Store setup and staff roles (optometrists, sales team, etc.)
- Product catalog (frames, lenses, contact lenses, accessories)
- Supplier and purchase order management
- Store-wise inventory tracking
- Eye-test appointments and prescriptions
- Orders, payments, and fulfillment lifecycle

---

## 🏗️ Database Architecture

The schema is structured into the following modules:

| Module | Description |
|-------|------------|
| **Master Tables** | Customers, Addresses, Stores, Staff, Product Categories, Products, Suppliers |
| **Inventory & Procurement** | Purchase Orders, Purchase Order Items, Store Inventory |
| **Appointments & Prescriptions** | Eye Test Appointments, Prescriptions |
| **Orders & Payments** | Orders, Order Items, Payments |

The design ensures:

- **Referential integrity** using foreign keys  
- **Transactional consistency** for orders and payments  
- **Scalability** for multiple stores, product categories, and prescriptions  
- **Real retail behaviors** like cancellations, no-shows, order returns, etc.

---

## 📂 Schema ER Diagram

> ![image](https://github.com/user-attachments/assets/ca2f788b-5f7f-4fa6-8897-1d5464a6f9f6)

## 📂 Group Members
- Pavani Singhal- 341093
- M Janani Sree-341085
- Arya Verma-341070
