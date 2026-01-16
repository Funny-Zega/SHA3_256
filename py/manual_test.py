import serial
import time
import sys

# ==============================================================================
# CONFIGURATION (MUST CHANGE 'COMx' TO YOUR ACTUAL PORT)
# ==============================================================================
# Windows: 'COMx' (e.g., 'COM3', 'COM4')
# Linux/Mac: '/dev/ttyUSB1' or '/dev/ttyACM0'
PORT_NAME = 'COM6'   
BAUD_RATE = 115200    # Must match the BAUD parameter in Verilog

def run_test():
    try:
        # Open Serial connection
        ser = serial.Serial(PORT_NAME, BAUD_RATE, timeout=2.0)
        print(f"\n[SUCCESS] Connected to {PORT_NAME} at {BAUD_RATE} baud.")
        print("Note: Press the RESET button on the FPGA before starting to ensure a clean state.\n")
        
        while True:
            # 1. Get input from user
            user_input = input(">> Enter string to Hash (type 'exit' to quit): ")
            
            # if user_input.lower() == 'exit':
            #     print("Exiting...")
            #     break
            
            # 2. Send data to FPGA
            # Encode to bytes and add '\n' (0x0A) as delimiter to trigger hash
            data_to_send = user_input.encode('utf-8') + b'\n'
            
            print(f"   [PC -> FPGA] Sending {len(data_to_send) - 1} bytes...")
            ser.write(data_to_send)
            
            # 3. Wait for result (32 bytes = 256 bits)
            start_time = time.time()
            response = ser.read(32)
            end_time = time.time()
            
            # 4. Check and display result
            if len(response) == 32:
                # Convert bytes to Hex string
                hash_hex = response.hex()
                duration = (end_time - start_time) * 1000 # ms
                print(f"   [FPGA -> PC] Received 32 bytes (Response time: {duration:.9f}ms)")
                print(f"   ----------------------------------------------------------------")
                print(f"   RESULT: {hash_hex}")
                print(f"   ----------------------------------------------------------------\n")
            else:
                print(f"   [ERROR] Timeout! Received only {len(response)}/32 bytes.")
                print("   Suggestion: Press RESET on the FPGA and try again.\n")

    except serial.SerialException as e:
        print(f"\n[CONNECTION ERROR] Could not open port {PORT_NAME}.")
        print("1. Check the USB cable.")
        print("2. Check if the COM port is correct (in Device Manager).")
        print("3. Close other software occupying the COM port (like TeraTerm, Putty).")
        print(f"Error details: {e}")
    except Exception as e:
        print(f"\n[UNKNOWN ERROR]: {e}")
    finally:
        if 'ser' in locals() and ser.is_open:
            ser.close()
            print("[INFO] Serial port closed.")

if __name__ == "__main__":
    run_test()