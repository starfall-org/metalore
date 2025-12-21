#!/usr/bin/env python3
"""
Script quản lý translation files
Giữ nguyên khóa đã có, dịch và bổ sung khóa mới từ en.json
"""

import json
import sys
import asyncio
from pathlib import Path
from typing import Dict, Any, Set
import copy
import time
from googletrans import Translator

# Cấu hình các ngôn ngữ đích
TARGET_LANGUAGES = {
    'vi': 'Vietnamese',
    'de': 'German', 
    'es': 'Spanish',
    'fr': 'French',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh_CN': 'Chinese (Simplified)',
    'zh_TW': 'Chinese (Traditional)'
}

class TranslationManager:
    def __init__(self):
        self.translator = Translator()
        self.base_path = Path(__file__).parent.parent / "assets" / "translations"
        self.source_file = self.base_path / "en.json"
        
    def load_json_file(self, file_path: Path) -> Dict[str, Any]:
        """Đọc file JSON"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"❌ Không tìm thấy file: {file_path}")
            return {}
        except json.JSONDecodeError as e:
            print(f"❌ Lỗi đọc JSON {file_path}: {e}")
            return {}
    
    def save_json_file(self, file_path: Path, data: Dict[str, Any]):
        """Lưu file JSON với format đẹp"""
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"💾 Đã lưu: {file_path}")
        except Exception as e:
            print(f"❌ Lỗi lưu file {file_path}: {e}")
    
    def get_all_keys(self, data: Dict[str, Any], prefix: str = "") -> Set[str]:
        """Lấy tất cả keys từ nested dictionary"""
        keys = set()
        for key, value in data.items():
            full_key = f"{prefix}.{key}" if prefix else key
            if isinstance(value, dict):
                keys.update(self.get_all_keys(value, full_key))
            else:
                keys.add(full_key)
        return keys
    
    def get_value_by_path(self, data: Dict[str, Any], path: str) -> Any:
        """Lấy giá trị theo path (ví dụ: 'home.title')"""
        keys = path.split('.')
        current = data
        for key in keys:
            if isinstance(current, dict) and key in current:
                current = current[key]
            else:
                return None
        return current
    
    def set_value_by_path(self, data: Dict[str, Any], path: str, value: Any):
        """Set giá trị theo path (ví dụ: 'home.title')"""
        keys = path.split('.')
        current = data
        for key in keys[:-1]:
            if key not in current:
                current[key] = {}
            current = current[key]
        current[keys[-1]] = value
    
    async def translate_text(self, text: str, dest_lang: str) -> str:
        """Dịch một đoạn văn bản"""
        if not text or text.strip() == "":
            return text
            
        try:
            # Thêm delay để tránh rate limiting
            time.sleep(0.1)
            result = await self.translator.translate(text, src='en', dest=dest_lang)
            return result.text
        except Exception as e:
            print(f"⚠️  Lỗi dịch '{text[:50]}...': {e}")
            return text  # Trả về text gốc nếu lỗi
    
    async def translate_value(self, value: Any, dest_lang: str) -> Any:
        """Dịch giá trị (có thể là string, dict, hoặc list)"""
        if isinstance(value, str):
            return await self.translate_text(value, dest_lang)
        elif isinstance(value, dict):
            return {k: await self.translate_value(v, dest_lang) for k, v in value.items()}
        elif isinstance(value, list):
            return [await self.translate_value(item, dest_lang) for item in value]
        else:
            return value
    
    async def merge_and_translate_new_keys(self, source_data: Dict[str, Any], target_data: Dict[str, Any], dest_lang: str) -> tuple[Dict[str, Any], bool]:
        """Merge source data vào target data, chỉ dịch và thêm key mới
        
        Returns:
            tuple: (merged_data, has_translated) - data đã merge và flag cho biết có dịch hay không
        """
        result = copy.deepcopy(target_data)
        
        # Lấy tất cả keys từ source
        source_keys = self.get_all_keys(source_data)
        
        # Lấy tất cả keys từ target
        target_keys = self.get_all_keys(target_data)
        
        # Tìm keys mới cần dịch và thêm
        new_keys = source_keys - target_keys
        
        print(f"📊 Thống kê:")
        print(f"  • Tổng keys trong source: {len(source_keys)}")
        print(f"  • Keys đã có trong target: {len(target_keys)}")
        print(f"  • Keys mới cần dịch: {len(new_keys)}")
        
        if not new_keys:
            print("✅ Không có key mới nào cần dịch")
            return result, False
        
        # Dịch và thêm các key mới
        for key_path in sorted(new_keys):
            value = self.get_value_by_path(source_data, key_path)
            if value is not None:
                print(f"🌐 Đang dịch: {key_path}")
                translated_value = await self.translate_value(value, dest_lang)
                self.set_value_by_path(result, key_path, translated_value)
                print(f"➕ Đã dịch và thêm: {key_path}")
        
        return result, True
    
    async def process_language(self, lang_code: str) -> bool:
        """Xử lý một ngôn ngữ cụ thể
        
        Returns:
            bool: True nếu có dịch, False nếu không có key mới
        """
        if lang_code not in TARGET_LANGUAGES:
            print(f"❌ Ngôn ngữ không được hỗ trợ: {lang_code}")
            print(f"📋 Các ngôn ngữ có sẵn: {', '.join(TARGET_LANGUAGES.keys())}")
            return False
        
        print(f"🎯 Xử lý {TARGET_LANGUAGES[lang_code]} ({lang_code})...")
        
        # Load source file
        source_data = self.load_json_file(self.source_file)
        if not source_data:
            return False
        
        # Load target file
        target_file = self.base_path / f"{lang_code}.json"
        target_data = self.load_json_file(target_file)
        
        # Merge và dịch key mới
        merged_data, has_translated = await self.merge_and_translate_new_keys(source_data, target_data, lang_code)
        
        # Save
        self.save_json_file(target_file, merged_data)
        
        print(f"✅ Hoàn thành xử lý {TARGET_LANGUAGES[lang_code]}!")
        return has_translated
    
    async def process_all_languages(self):
        """Xử lý tất cả các ngôn ngữ"""
        print("🚀 Bắt đầu quá trình merge và dịch translation files...")
        print(f"📂 File nguồn: {self.source_file}")
        
        # Load source file
        source_data = self.load_json_file(self.source_file)
        if not source_data:
            print("❌ Không thể load file nguồn!")
            return
        
        print(f"📖 Đã đọc {len(self.get_all_keys(source_data))} keys từ file nguồn")
        
        # Xử lý từng ngôn ngữ
        for lang_code, lang_name in TARGET_LANGUAGES.items():
            print(f"\n{'='*50}")
            try:
                has_translated = await self.process_language(lang_code)
                if has_translated:
                    # Chỉ delay nếu đã thực sự dịch để tránh rate limiting
                    await asyncio.sleep(1)
                # Nếu không có dịch thì không cần sleep
            except Exception as e:
                print(f"❌ Lỗi xử lý {lang_name}: {e}")
        
        print(f"\n{'='*50}")
        print("🎊 Hoàn thành tất cả translation files!")
    
    def list_languages(self):
        """Liệt kê các ngôn ngữ được hỗ trợ"""
        print("📋 Các ngôn ngữ được hỗ trợ:")
        for code, name in TARGET_LANGUAGES.items():
            file_path = self.base_path / f"{code}.json"
            status = "✅ Có file" if file_path.exists() else "❌ Chưa có file"
            print(f"  • {code}: {name} - {status}")
    
    def check_missing_keys(self, lang_code: str):
        """Kiểm tra các key còn thiếu trong một ngôn ngữ"""
        if lang_code not in TARGET_LANGUAGES:
            print(f"❌ Ngôn ngữ không được hỗ trợ: {lang_code}")
            return
        
        source_data = self.load_json_file(self.source_file)
        target_file = self.base_path / f"{lang_code}.json"
        target_data = self.load_json_file(target_file)
        
        if not source_data:
            return
        
        source_keys = self.get_all_keys(source_data)
        target_keys = self.get_all_keys(target_data) if target_data else set()
        missing_keys = source_keys - target_keys
        
        print(f"🔍 Kiểm tra key thiếu cho {TARGET_LANGUAGES[lang_code]} ({lang_code}):")
        print(f"  • Tổng keys trong source: {len(source_keys)}")
        print(f"  • Keys đã có: {len(target_keys)}")
        print(f"  • Keys còn thiếu: {len(missing_keys)}")
        
        if missing_keys:
            print(f"\n📝 Các key còn thiếu:")
            for key in sorted(missing_keys):
                print(f"  • {key}")

async def main():
    """Hàm chính"""
    print("🔤 Translation Manager - Merge và Dịch Key Mới")
    print("=" * 60)
    
    manager = TranslationManager()
    
    # Kiểm tra tham số dòng lệnh
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "--list" or command == "-l":
            manager.list_languages()
            return
        
        if command == "--check" or command == "-c":
            if len(sys.argv) > 2:
                lang_code = sys.argv[2]
                manager.check_missing_keys(lang_code)
            else:
                print("❌ Vui lòng chỉ định mã ngôn ngữ. Ví dụ: python translate.py --check vi")
            return
        
        if command in TARGET_LANGUAGES:
            # Xử lý một ngôn ngữ cụ thể
            await manager.process_language(command)
        else:
            print(f"❌ Lệnh không hợp lệ: {command}")
            print(f"📋 Sử dụng:")
            print(f"  • Không có tham số: Xử lý tất cả ngôn ngữ")
            print(f"  • --list (-l): Liệt kê các ngôn ngữ")
            print(f"  • --check (-c) <lang_code>: Kiểm tra key thiếu")
            print(f"  • <lang_code>: Xử lý một ngôn ngữ cụ thể")
            print(f"\n📋 Các ngôn ngữ có sẵn: {', '.join(TARGET_LANGUAGES.keys())}")
    else:
        # Xử lý tất cả các ngôn ngữ
        await manager.process_all_languages()

if __name__ == "__main__":
    asyncio.run(main())