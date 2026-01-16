import serial
import time

PORT = 'COM6'  # <--- ĐỔI THÀNH CỔNG COM CỦA PMOD
BAUDRATE = 115200
INPUT_FILE = 'input.txt'

def run_test():
    try:
        ser = serial.Serial(PORT, BAUDRATE, timeout=1)
        print(f"Connected to {PORT}")
        time.sleep(0.1)
        
        # Đọc file input
        with open(INPUT_FILE, 'r') as f:
            lines = f.readlines()
            
        print(f"Tìm thấy {len(lines)} test cases.\n")
        
        for i, line in enumerate(lines):
            # Xóa ký tự xuống dòng thừa (\n)
            test_str = line.strip()
            
            if not test_str: continue # Bỏ qua dòng trống

            print(f"Test {i+1}: Input = '{test_str}'")
            
            # Gửi: String + 0x0D
            ser.write(test_str.encode('ascii') + b'\r')
            
            # Đợi nhận 32 bytes
            start_time = time.time()
            response = ser.read(32)
            end_time = time.time()
            
            if len(response) == 32:
                print(f"   -> Hash: {response.hex()}")
                print(f"   -> Time: {(end_time - start_time)*1000:.2f} ms")
            else:
                print("   -> FAIL: Timeout hoặc mất dữ liệu.")
                
            print("-" * 30)
            
            # Nghỉ 1 chút giữa các lần gửi để FPGA kịp reset buffer (tùy mạch)
            time.sleep(0.1) 

        ser.close()
        print("\nHoàn thành tất cả test cases.")

    except Exception as e:
        print(f"Có lỗi xảy ra: {e}")

if __name__ == "__main__":
    run_test()