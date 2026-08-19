from faker import Faker
fake = Faker()

print("Potential Partner Pairs:\n")
for i in range(20):
    name1 = fake.name_male()
    name2 = fake.name_male()
    print(f"{i+1}. {name1} & {name2}")

print("\n" + "="*50 + "\n")
