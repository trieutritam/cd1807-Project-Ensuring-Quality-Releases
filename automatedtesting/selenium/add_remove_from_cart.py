# #!/usr/bin/env python
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
#
# pip install -U selenium
#

# Start the browser and login with standard_user
def login (user, password):
    print ('Starting the browser...')
    # Execute Chrome in headless mode
    options = ChromeOptions()
    options.add_argument("--headless")
    driver = webdriver.Chrome(options=options)
    # driver = webdriver.Chrome()
    print ('Browser started successfully. Navigating to the demo page to login.')
    driver.get('https://www.saucedemo.com/')

    print ('Login with ' + user)
    driver.find_element(By.CSS_SELECTOR, "input[data-test='username']").send_keys(user)
    driver.find_element(By.CSS_SELECTOR, "input[data-test='password']").send_keys(password)
    driver.find_element(By.CSS_SELECTOR, "input[data-test='login-button']").click()

    element = WebDriverWait(driver, 10).until(
      EC.presence_of_element_located((By.CSS_SELECTOR, "div[data-test='secondary-header'] > [data-test='title']")))

    assert "Products" in element.text
    print('Login successfully')

    return driver

def add_item_to_cart(driver):
  print('Load inventory page for adding items to cart')
  driver.get('https://www.saucedemo.com/inventory.html')
  items = driver.find_elements(By.CSS_SELECTOR, ".inventory_list > div[data-test='inventory-item']")
  print("Inventory items: ", len(items))
  assert len(items) > 0, "Inventory items must greater than 0"
  for item in items:
    item_name = item.find_element(By.CSS_SELECTOR, ".inventory_item_label > a").text
    item_add_btn = item.find_element(By.CSS_SELECTOR, "button.btn_inventory")
    item_add_btn.click()
    print("  - Added item: " + item_name)

  print('Get cart item to verify the item is in the carts')
  driver.get('https://www.saucedemo.com/cart.html')
  items = driver.find_elements(By.CSS_SELECTOR, "div.cart_item")
  item_count = len(items)
  print(f'Verify cart items count should be 6, actual: {item_count}')
  assert item_count == 6

def remove_item_from_cart(driver):
  print('Load cart page for removing items')
  driver.get('https://www.saucedemo.com/cart.html')
  items = driver.find_elements(By.CSS_SELECTOR, "div.cart_item")
  for item in items:
    label = item.find_element(By.CSS_SELECTOR, ".cart_item_label > a").text
    btn = item.find_element(By.CSS_SELECTOR, "button.cart_button")
    btn.click()
    print('  - Removed item: ' + label)

  items = driver.find_elements(By.CSS_SELECTOR, "div.cart_item")
  item_count = len(items)
  print(f'Verify cart items count should be 0, actual: {item_count}')
  assert item_count == 0

print('----- Login to page -------')
driver = login('standard_user', 'secret_sauce')

print('----- Add Item to Cart -------')
add_item_to_cart(driver)

print('----- Remove Item from Cart -------')
remove_item_from_cart(driver)