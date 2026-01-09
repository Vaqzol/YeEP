# สรุปเพื่อเตรียมตอบคำถาม - หลักการ OOP และ Algorithm

---

## 1. หลักการ OOP (Object-Oriented Programming)

### 1.1 OOP คืออะไร?
**Object-Oriented Programming (OOP)** คือ แนวคิดในการเขียนโปรแกรมที่มองทุกอย่างเป็น **"วัตถุ" (Object)** 

**Object** ประกอบด้วย:
- **Attributes (คุณสมบัติ)** - ข้อมูลที่ Object เก็บ เช่น ชื่อ, อายุ, สี
- **Methods (พฤติกรรม)** - สิ่งที่ Object ทำได้ เช่น เดิน, พูด, คำนวณ

**ตัวอย่างในชีวิตจริง:**
```
Object: รถยนต์
├── Attributes: สี, ยี่ห้อ, รุ่น, ความเร็ว
└── Methods: เร่งความเร็ว(), เบรก(), เลี้ยว()
```

---

### 1.2 Inheritance (การสืบทอด)

#### นิยาม
**Inheritance** คือ กระบวนการที่ Class หนึ่ง **รับ (สืบทอด)** คุณสมบัติและพฤติกรรมจาก Class อื่น

#### คำศัพท์
| คำ | ความหมาย |
|----|----------|
| **Superclass / Parent** | Class ที่ถูกสืบทอด (Class แม่) |
| **Subclass / Child** | Class ที่สืบทอด (Class ลูก) |
| **extends** | คำสั่งในการสืบทอด |

#### ตัวอย่างในชีวิตจริง
```
สัตว์ (Superclass)
├── หมา (Subclass) - สืบทอด: กิน, นอน, หายใจ + เพิ่ม: เห่า
├── แมว (Subclass) - สืบทอด: กิน, นอน, หายใจ + เพิ่ม: ร้องเหมียว
└── นก (Subclass) - สืบทอด: กิน, นอน, หายใจ + เพิ่ม: บิน
```

#### ในโปรเจค YeEP
```java
// BaseEntity = Superclass (Class แม่)
public abstract class BaseEntity {
    protected Long id;
    protected LocalDateTime createdAt;
    protected LocalDateTime updatedAt;
}

// User = Subclass (Class ลูก) - สืบทอดจาก BaseEntity
public class User extends BaseEntity {
    private String username;  // เพิ่มเอง
    private String email;     // เพิ่มเอง
    // id, createdAt, updatedAt ได้มาจาก BaseEntity โดยอัตโนมัติ
}
```

#### ประโยชน์
1. **ลด code ซ้ำ** - เขียน id, createdAt ครั้งเดียวใน BaseEntity
2. **แก้ไขง่าย** - แก้ที่ BaseEntity มีผลกับทุก Entity
3. **โครงสร้างเป็นระบบ** - ทุก Entity มี format เดียวกัน

---

### 1.3 Polymorphism (ความหลากหลาย)

#### นิยาม
**Polymorphism** คือ ความสามารถที่ Object หลายชนิด **ตอบสนองต่อ method เดียวกัน** ได้ในรูปแบบที่ต่างกัน

#### ตัวอย่างในชีวิตจริง
```
method: makeSound()
├── หมา.makeSound() → "โฮ่ง โฮ่ง"
├── แมว.makeSound() → "เหมียว"
└── นก.makeSound() → "จิ๊บ จิ๊บ"
```
**ทุกตัวใช้ method เดียวกัน (`makeSound`) แต่ผลลัพธ์ต่างกัน**

#### ในโปรเจค YeEP
```java
// JpaRepository = Interface กำหนด method ที่ต้องมี
public interface JpaRepository<T, ID> {
    T save(T entity);
    List<T> findAll();
    void delete(T entity);
}

// ทุก Repository ใช้ method เดียวกัน แต่ทำงานกับ Entity ต่างกัน
BookingRepository.save(booking)  → บันทึก Booking
UserRepository.save(user)        → บันทึก User
BusRouteRepository.save(route)   → บันทึก BusRoute
```

#### ประโยชน์
1. **ใช้ method เดียวกัน** - `repo.save()` ใช้ได้กับทุก Entity
2. **ลด code ซ้ำ** - ไม่ต้องเขียน save แยกแต่ละ Entity
3. **ยืดหยุ่น** - เพิ่ม Entity ใหม่ได้ง่าย

---

### 1.4 Aggregation (ความสัมพันธ์แบบหลวม)

#### นิยาม
**Aggregation** คือ ความสัมพันธ์ **"has-a" (มี)** ที่ Part (ส่วนย่อย) **สามารถอยู่ได้** โดยไม่มี Whole (ส่วนใหญ่)

#### หลักการ
> **ลบ Whole ≠ ลบ Part**

#### ตัวอย่างในชีวิตจริง
```
บริษัท (Whole) ──────> พนักงาน (Part)
```
- บริษัท "มี" พนักงาน
- ถ้าบริษัทปิดตัว พนักงานยังมีชีวิตอยู่ (ไปทำที่อื่นได้)

#### ในโปรเจค YeEP
```java
public class Booking {
    @ManyToOne
    private User user;      // Booking "มี" User
    
    @ManyToOne
    private BusTrip trip;   // Booking "มี" Trip
}
```
- ลบ Booking ไม่ได้ลบ User (User ยังอยู่)
- ลบ Booking ไม่ได้ลบ Trip (Trip ยังอยู่)

---

### 1.5 Composition (ความสัมพันธ์แบบแน่น)

#### นิยาม
**Composition** คือ ความสัมพันธ์ **"has-a" (มี)** ที่ Part (ส่วนย่อย) **ไม่สามารถอยู่ได้** โดยไม่มี Whole (ส่วนใหญ่)

#### หลักการ
> **ลบ Whole = ลบ Part ทั้งหมด**

#### ตัวอย่างในชีวิตจริง
```
บ้าน (Whole) ──────> ห้อง (Part)
```
- บ้าน "มี" ห้อง
- ถ้าทำลายบ้าน ห้องก็หายไปด้วย (ห้องอยู่ไม่ได้ถ้าไม่มีบ้าน)

#### ในโปรเจค YeEP
```java
public class TripSchedule {           // Whole
    private List<TripTimeSlot> timeSlots;  // Part
    
    public TripSchedule() {
        this.timeSlots = new ArrayList<>();  // สร้าง Part พร้อม Whole
    }
    
    public void destroy() {
        this.timeSlots.clear();  // ลบ Part ทั้งหมดเมื่อ Whole ถูกทำลาย
    }
}
```

---

### 1.6 สรุป Aggregation vs Composition

| หัวข้อ | Aggregation | Composition |
|--------|-------------|-------------|
| **ความสัมพันธ์** | หลวม (Weak) | แน่น (Strong) |
| **ลบ Whole** | Part ยังอยู่ | Part ถูกลบด้วย |
| **ตัวอย่าง** | บริษัท-พนักงาน | บ้าน-ห้อง |
| **ในโปรเจค** | Booking→User | TripSchedule→TimeSlot |

---

## 2. File Input/Output (การอ่าน/เขียนไฟล์)

### 2.1 File I/O คืออะไร?

**File I/O** คือ การทำงานกับไฟล์ในคอมพิวเตอร์

| ประเภท | ความหมาย | ตัวอย่าง |
|--------|----------|---------|
| **File Input** | อ่านข้อมูล **เข้า** โปรแกรม | อ่านไฟล์ .txt, .csv, รูปภาพ |
| **File Output** | เขียนข้อมูล **ออก** จากโปรแกรม | บันทึกไฟล์, export รายงาน |

### 2.2 ทำไมต้องใช้ File I/O?

**ปัญหา:** ข้อมูลในโปรแกรมหายเมื่อปิดโปรแกรม (เก็บใน RAM)

**แก้ไข:** เก็บข้อมูลลงไฟล์ (Persistent Storage) เพื่อใช้ภายหลัง

```
โปรแกรม (RAM) ←──File Input──── ไฟล์ (Hard Disk)
โปรแกรม (RAM) ───File Output──→ ไฟล์ (Hard Disk)
```

### 2.3 ประเภทไฟล์

| ประเภท | ลักษณะ | ตัวอย่าง |
|--------|--------|---------|
| **Text File** | ข้อความที่อ่านได้ | .txt, .csv, .json |
| **Binary File** | ข้อมูลดิบ (0, 1) | .jpg, .png, .pdf |

### 2.4 ในโปรเจค YeEP (FileService.java)

#### File Input - อ่านไฟล์

**1. อ่านไฟล์ Text:**
```java
public List<String> readTextFile(String filePath) throws IOException {
    List<String> lines = new ArrayList<>();
    
    // BufferedReader = ตัวอ่านไฟล์
    try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
        String line;
        // อ่านทีละบรรทัดจนหมดไฟล์
        while ((line = reader.readLine()) != null) {
            lines.add(line);
        }
    }
    
    return lines;
}
```

**การทำงาน:**
1. เปิดไฟล์ด้วย `FileReader`
2. ใช้ `BufferedReader` อ่านทีละบรรทัด
3. Loop อ่านจนกว่า `readLine()` จะคืนค่า `null` (หมดไฟล์)
4. ปิดไฟล์อัตโนมัติด้วย `try-with-resources`

**2. อ่านไฟล์ CSV:**
```java
public List<Map<String, String>> readCsvFile(String filePath) throws IOException {
    List<Map<String, String>> data = new ArrayList<>();
    List<String> lines = readTextFile(filePath);  // อ่าน Text ก่อน
    
    // บรรทัดแรก = Header (ชื่อ column)
    String[] headers = lines.get(0).split(",");  // แยกด้วย comma
    
    // บรรทัดที่ 2 เป็นต้นไป = ข้อมูล
    for (int i = 1; i < lines.size(); i++) {
        String[] values = lines.get(i).split(",");
        Map<String, String> row = new HashMap<>();
        
        for (int j = 0; j < headers.length; j++) {
            row.put(headers[j], values[j]);  // header = key, value = value
        }
        data.add(row);
    }
    return data;
}
```

**ตัวอย่าง CSV:**
```
name,age,city           ← Header
John,25,Bangkok         ← Data row 1
Jane,30,Nakhon Ratchasima  ← Data row 2
```

**ผลลัพธ์:**
```java
[
    {name: "John", age: "25", city: "Bangkok"},
    {name: "Jane", age: "30", city: "Nakhon Ratchasima"}
]
```

**3. อ่านรูปภาพ (Binary):**
```java
public byte[] readBinaryFile(String filePath) throws IOException {
    Path path = Paths.get(filePath);
    return Files.readAllBytes(path);  // อ่านทั้งไฟล์เป็น byte array
}
```

#### File Output - เขียนไฟล์

**1. เขียนไฟล์ Text:**
```java
public void writeTextFile(String filePath, String content) throws IOException {
    // BufferedWriter = ตัวเขียนไฟล์
    try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
        writer.write(content);  // เขียนเนื้อหา
    }
}
```

**2. บันทึกรูปโปรไฟล์:**
```java
public Map<String, Object> uploadProfileImage(String username, MultipartFile file) {
    // 1. ตรวจสอบไฟล์ (ขนาด, นามสกุล)
    Map<String, Object> validation = validateImageFile(filename, file.getSize());
    
    // 2. สร้างชื่อไฟล์ใหม่
    String newFilename = username + "_" + timestamp + extension;
    
    // 3. บันทึกไฟล์
    Path filePath = uploadPath.resolve(newFilename);
    Files.write(filePath, file.getBytes());  // เขียน binary
    
    return result;
}
```

### 2.5 สรุป File I/O ในโปรเจค

| Method | ประเภท | ทำอะไร |
|--------|--------|--------|
| `readTextFile()` | Input | อ่านไฟล์ .txt ทีละบรรทัด |
| `readCsvFile()` | Input | อ่านไฟล์ .csv แปลงเป็น Map |
| `readBinaryFile()` | Input | อ่านไฟล์รูปภาพเป็น byte[] |
| `writeTextFile()` | Output | เขียนไฟล์ .txt |
| `uploadProfileImage()` | Output | บันทึกรูปโปรไฟล์ |
| `getProfileImage()` | Input | ดึงรูปโปรไฟล์ |

---

## 3. Selection Sort (การเรียงลำดับ)

### 3.1 หลักการ
1. **หาค่าน้อยสุด** ในส่วนที่ยังไม่ได้เรียง
2. **สลับ** กับตำแหน่งแรกของส่วนที่ยังไม่เรียง
3. **ทำซ้ำ** จนครบ

### 3.2 ตัวอย่าง
```
เริ่มต้น: [64, 25, 12, 22, 11]

รอบ 1: หา min = 11, สลับกับ 64 → [11, 25, 12, 22, 64]
รอบ 2: หา min = 12, สลับกับ 25 → [11, 12, 25, 22, 64]
รอบ 3: หา min = 22, สลับกับ 25 → [11, 12, 22, 25, 64]
รอบ 4: หา min = 25 (อยู่แล้ว) → [11, 12, 22, 25, 64]

เสร็จ: [11, 12, 22, 25, 64] ✓
```

### 3.3 Complexity
- **Time:** O(n²) - วน 2 loop ซ้อนกัน
- **Space:** O(1) - ไม่ใช้ memory เพิ่ม

---

## 4. Sequential Search (การค้นหา)

### 4.1 หลักการ
1. **วนลูป** ตรวจสอบทีละ element
2. **เปรียบเทียบ** กับเงื่อนไข
3. **เพิ่มเข้าผลลัพธ์** ถ้าตรง

### 4.2 ตัวอย่าง
```
ค้นหา: "นครราชสีมา" ใน ["กรุงเทพ", "นครราชสีมา", "เชียงใหม่", "ขอนแก่น"]

ตรวจ "กรุงเทพ" - ไม่ตรง
ตรวจ "นครราชสีมา" - ตรง! → พบแล้ว ✓
```

### 4.3 Complexity
- **Time:** O(n) - วน 1 loop
- **Space:** O(1) - ไม่ใช้ memory เพิ่ม

---

## 5. File Input/Output ใน Java Backend (การเปลี่ยนรูปโปรไฟล์)

### 🎯 Flow ใหม่ (ผ่าน Java Backend)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FLOW ผ่าน Java Backend                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  [Flutter App]                         [Java Backend]                       │
│                                                                             │
│  1. กดเปลี่ยนรูป                                                             │
│     ↓                                                                       │
│  2. ถ่าย/เลือกรูป                                                            │
│     ↓                                                                       │
│  3. ส่งรูปไป API ─────────────────────▶ 4. FileController รับ request       │
│     POST /api/files/profile/{username}      ↓                               │
│                                        5. FileService.uploadProfileImage()  │
│                                             ↓                               │
│                                        6. Files.write() ← FILE OUTPUT (Java)│
│                                             ↓                               │
│  8. แสดงผลสำเร็จ ◀──────────────────── 7. ส่ง response กลับ                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 📍 Java Code - FileController.java (รับ Request)

```java
@RestController
@RequestMapping("/api/files")
public class FileController {

    @Autowired
    private FileService fileService;

    /**
     * API รับไฟล์รูปโปรไฟล์จาก Flutter App
     * 
     * URL: POST /api/files/profile/{username}
     * 
     * @param username ชื่อผู้ใช้
     * @param file     ไฟล์รูปที่ส่งมา (MultipartFile)
     */
    @PostMapping("/profile/{username}")
    public ResponseEntity<Map<String, Object>> uploadProfileImage(
            @PathVariable String username,
            @RequestParam("file") MultipartFile file) {

        // เรียก FileService ทำงาน (FILE OUTPUT อยู่ใน Service)
        Map<String, Object> result = fileService.uploadProfileImage(username, file);

        if ((boolean) result.get("success")) {
            return ResponseEntity.ok(result);
        } else {
            return ResponseEntity.badRequest().body(result);
        }
    }
}
```

---

### 📍 Java Code - FileService.java (FILE OUTPUT!)

```java
@Service
public class FileService {

    /** โฟลเดอร์เก็บไฟล์อัพโหลด */
    private static final String UPLOAD_DIR = "uploads";
    
    /** โฟลเดอร์เก็บรูปโปรไฟล์ */
    private static final String PROFILE_DIR = "profiles";

    /**
     * บันทึกรูปโปรไฟล์ลง Hard Disk (FILE OUTPUT!)
     * 
     * @param username ชื่อผู้ใช้
     * @param file     ไฟล์รูปที่ส่งมา
     * @return ผลลัพธ์การบันทึก
     */
    public Map<String, Object> uploadProfileImage(String username, MultipartFile file) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 1. ตรวจสอบไฟล์
            String originalFilename = file.getOriginalFilename();
            Map<String, Object> validation = validateImageFile(originalFilename, file.getSize());

            if (!(boolean) validation.get("valid")) {
                result.put("success", false);
                result.put("validation", validation);
                return result;
            }

            // 2. สร้างโฟลเดอร์ถ้ายังไม่มี
            Path uploadPath = Paths.get(UPLOAD_DIR, PROFILE_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            // 3. สร้างชื่อไฟล์ใหม่
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String timestamp = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
            String newFilename = username + "_" + timestamp + extension;
            // newFilename = "john_20260109_130000.jpg"

            // 4. บันทึกไฟล์ลง Hard Disk (FILE OUTPUT!)
            Path filePath = uploadPath.resolve(newFilename);
            Files.write(filePath, file.getBytes());  // ← นี่คือ FILE OUTPUT!

            result.put("success", true);
            result.put("filename", newFilename);
            result.put("path", filePath.toString());
            result.put("size", file.getSize());

        } catch (IOException e) {
            result.put("success", false);
            result.put("error", "ไม่สามารถบันทึกไฟล์ได้: " + e.getMessage());
        }

        return result;
    }
}
```

**🔍 FILE OUTPUT อยู่ตรงไหน?**
```java
Files.write(filePath, file.getBytes());  // ← FILE OUTPUT!
```
- `file.getBytes()` = ข้อมูลรูปภาพจาก Flutter (byte array)
- `filePath` = path ที่จะบันทึก (uploads/profiles/john_xxx.jpg)
- `Files.write()` = **เขียนไฟล์ลง Hard Disk**

---

### 📍 Java Code - FileService.java (FILE INPUT!)

```java
/**
 * ดึงรูปโปรไฟล์ของผู้ใช้ (FILE INPUT!)
 * 
 * @param username ชื่อผู้ใช้
 * @return ข้อมูลรูปเป็น byte array หรือ null หากไม่พบ
 */
public byte[] getProfileImage(String username) {
    try {
        Path profileDir = Paths.get(UPLOAD_DIR, PROFILE_DIR);

        if (!Files.exists(profileDir)) {
            return null;
        }

        // ค้นหาไฟล์ที่ขึ้นต้นด้วย username
        Optional<Path> profileFile = Files.list(profileDir)
                .filter(path -> path.getFileName().toString().startsWith(username + "_"))
                .sorted(Comparator.reverseOrder()) // เอาไฟล์ล่าสุด
                .findFirst();

        if (profileFile.isPresent()) {
            // FILE INPUT! - อ่านไฟล์จาก Hard Disk
            return Files.readAllBytes(profileFile.get());
        }

    } catch (IOException e) {
        System.err.println("Error reading profile image: " + e.getMessage());
    }

    return null;
}
```

**🔍 FILE INPUT อยู่ตรงไหน?**
```java
return Files.readAllBytes(profileFile.get());  // ← FILE INPUT!
```
- `profileFile.get()` = path ของรูปโปรไฟล์
- `Files.readAllBytes()` = **อ่านไฟล์จาก Hard Disk เป็น byte array**

---

### 📁 Path ไฟล์ใน Server

```
yeep_backend/
└── uploads/
    └── profiles/
        ├── john_20260109_130000.jpg    ← รูปโปรไฟล์ของ john
        ├── jane_20260109_140000.jpg    ← รูปโปรไฟล์ของ jane
        └── bob_20260109_150000.jpg     ← รูปโปรไฟล์ของ bob
```

---

### 🔄 สรุป Java File I/O

| Method | ประเภท | Java Code | ทำอะไร |
|--------|--------|-----------|--------|
| `uploadProfileImage()` | **OUTPUT** | `Files.write(path, bytes)` | เขียนรูปลง uploads/profiles/ |
| `getProfileImage()` | **INPUT** | `Files.readAllBytes(path)` | อ่านรูปจาก uploads/profiles/ |
| `readTextFile()` | INPUT | `BufferedReader.readLine()` | อ่านไฟล์ text |
| `writeTextFile()` | OUTPUT | `BufferedWriter.write()` | เขียนไฟล์ text |
| `readBinaryFile()` | INPUT | `Files.readAllBytes()` | อ่านไฟล์ binary |
| `writeBinaryFile()` | OUTPUT | `Files.write()` | เขียนไฟล์ binary |

---

### 🎓 สรุปง่ายๆ

**Java FILE OUTPUT (เขียนไฟล์):**
```java
// เขียน binary (รูปภาพ)
Files.write(filePath, file.getBytes());

// เขียน text
BufferedWriter writer = new BufferedWriter(new FileWriter(path));
writer.write(content);
```

**Java FILE INPUT (อ่านไฟล์):**
```java
// อ่าน binary (รูปภาพ)
byte[] data = Files.readAllBytes(filePath);

// อ่าน text
BufferedReader reader = new BufferedReader(new FileReader(path));
String line = reader.readLine();
```

---

## 6. คำถาม-คำตอบ

### Q1: OOP คืออะไร?
**A:** การเขียนโปรแกรมแบบมองทุกอย่างเป็น Object ที่มี Attributes (ข้อมูล) และ Methods (พฤติกรรม)

### Q2: Inheritance ช่วยอะไร?
**A:** ลด code ซ้ำ - Entity ทุกตัวได้ id, createdAt จาก BaseEntity โดยอัตโนมัติ

### Q3: Aggregation กับ Composition ต่างกันอย่างไร?
**A:** Aggregation - ลบ Whole ไม่ลบ Part (Booking→User)
Composition - ลบ Whole = ลบ Part (TripSchedule→TimeSlot)

### Q4: File Input คืออะไร?
**A:** การอ่านข้อมูลจากไฟล์เข้ามาในโปรแกรม เช่น อ่าน .txt, .csv, รูปภาพ

### Q5: ทำไมใช้ Selection Sort?
**A:** เข้าใจง่าย, ใช้ Memory น้อย, ข้อมูลขนาดเล็ก

### Q6: ทำไมใช้ Sequential Search?
**A:** ข้อมูลไม่ต้องเรียงก่อน, รองรับ partial match (ค้นหาบางส่วน)
