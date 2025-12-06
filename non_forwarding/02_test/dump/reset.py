# ================================================================
# Script: make_reset_hex.py
# Mục đích: Tạo file reset.hex gồm 512 word (32-bit) toàn số 0
# ================================================================

def generate_reset_hex(filename="reset.hex", words=512):
    """Tạo file .hex gồm <words> dòng, mỗi dòng là 00000000"""
    with open(filename, "w") as f:
        for _ in range(words):
            f.write("00000000\n")
    print(f" Đã tạo file '{filename}' với {words} dòng toàn số 0 (32-bit).")

if __name__ == "__main__":
    generate_reset_hex()
