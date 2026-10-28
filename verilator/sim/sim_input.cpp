#include "sim_console.h"
#include "sim_input.h"

#include <string>
#include <stdlib.h>

#ifndef _MSC_VER
#include <SDL2/SDL.h>
extern bool headless;
int m_keyboardStateCount;
const Uint8* m_keyboardState;
Uint8* m_keyboardState_last = NULL;
#else
#define WIN32
#include <dinput.h>
IDirectInput8* m_directInput;
IDirectInputDevice8* m_keyboard;
unsigned char m_keyboardState[256];
unsigned char m_keyboardState_last[256];
#endif

#include <vector>

static DebugConsole console;

#ifdef WIN32
static const unsigned int ev2ps2[] =
{
	PS2_NONE, // 0   key_reserved
	0x76, // 1   key_esc
	0x16, // 2   key_1
	0x1e, // 3   key_2
	0x26, // 4   key_3
	0x25, // 5   key_4
	0x2e, // 6   key_5
	0x36, // 7   key_6
	0x3d, // 8   key_7
	0x3e, // 9   key_8
	0x46, // 10  key_9
	0x45, // 11  key_0
	0x4e, // 12  key_minus
	0x55, // 13  key_equal
	0x66, // 14  key_backspace
	0x0d, // 15  key_tab
	0x15, // 16  key_q
	0x1d, // 17  key_w
	0x24, // 18  key_e
	0x2d, // 19  key_r
	0x2c, // 20  key_t
	0x35, // 21  key_y
	0x3c, // 22  key_u
	0x43, // 23  key_i
	0x44, // 24  key_o
	0x4d, // 25  key_p
	0x54, // 26  key_leftbrace
	0x5b, // 27  key_rightbrace
	0x5a, // 28  key_enter
	 0x14, // 29  key_leftctrl
	0x1c, // 30  key_a
	0x1b, // 31  key_s
	0x23, // 32  key_d
	0x2b, // 33  key_f
	0x34, // 34  key_g
	0x33, // 35  key_h
	0x3b, // 36  key_j
	0x42, // 37  key_k
	0x4b, // 38  key_l
	0x4c, // 39  key_semicolon
	0x52, // 40  key_apostrophe
	0x0e, // 41  key_grave
	 0x12, // 42  key_leftshift
	0x5d, // 43  key_backslash
	0x1a, // 44  key_z
	0x22, // 45  key_x
	0x21, // 46  key_c
	0x2a, // 47  key_v
	0x32, // 48  key_b
	0x31, // 49  key_n
	0x3a, // 50  key_m
	0x41, // 51  key_comma
	0x49, // 52  key_dot
	0x4a, // 53  key_slash
	 0x59, // 54  key_rightshift
	0x7c, // 55  key_kpasterisk
	 0x11, // 56  key_leftalt
	0x29, // 57  key_space
	0x58, // 58  key_capslock
	0x05, // 59  key_f1
	0x06, // 60  key_f2
	0x04, // 61  key_f3
	0x0c, // 62  key_f4
	0x03, // 63  key_f5
	0x0b, // 64  key_f6
	0x83, // 65  key_f7
	0x0a, // 66  key_f8
	0x01, // 67  key_f9
	0x09, // 68  key_f10
	EMU_SWITCH_2 | 0x77, // 69  key_numlock
	EMU_SWITCH_1 | 0x7E, // 70  key_scrolllock
	0x6c, // 71  key_kp7
	0x75, // 72  key_kp8
	0x7d, // 73  key_kp9
	0x7b, // 74  key_kpminus
	0x6b, // 75  key_kp4
	0x73, // 76  key_kp5
	0x74, // 77  key_kp6
	0x79, // 78  key_kpplus
	0x69, // 79  key_kp1
	0x72, // 80  key_kp2
	0x7a, // 81  key_kp3
	0x70, // 82  key_kp0
	0x71, // 83  key_kpdot
	PS2_NONE, // 84  ???
	PS2_NONE, // 85  key_zenkaku
	0x61, // 86  key_102nd
	0x78, // 87  key_f11
	0x07, // 88  key_f12
	PS2_NONE, // 89  key_ro
	PS2_NONE, // 90  key_katakana
	PS2_NONE, // 91  key_hiragana
	PS2_NONE, // 92  key_henkan
	PS2_NONE, // 93  key_katakana
	PS2_NONE, // 94  key_muhenkan
	PS2_NONE, // 95  key_kpjpcomma
	EXT | 0x5a, // 96  key_kpenter
	 EXT | 0x14, // 97  key_rightctrl
	EXT | 0x4a, // 98  key_kpslash
	0xE2, // 99  key_sysrq
	 EXT | 0x11, // 100 key_rightalt
	PS2_NONE, // 101 key_linefeed
	EXT | 0x6c, // 102 key_home
	EXT | 0x75, // 103 key_up
	EXT | 0x7d, // 104 key_pageup
	EXT | 0x6b, // 105 key_left
	EXT | 0x74, // 106 key_right
	EXT | 0x69, // 107 key_end
	EXT | 0x72, // 108 key_down
	EXT | 0x7a, // 109 key_pagedown
	EXT | 0x70, // 110 key_insert
	EXT | 0x71, // 111 key_delete
	PS2_NONE, // 112 key_macro
	PS2_NONE, // 113 key_mute
	PS2_NONE, // 114 key_volumedown
	PS2_NONE, // 115 key_volumeup
	PS2_NONE, // 116 key_power
	PS2_NONE, // 117 key_kpequal
	PS2_NONE, // 118 key_kpplusminus
	0xE1, // 119 key_pause
	PS2_NONE, // 120 key_scale
	PS2_NONE, // 121 key_kpcomma
	PS2_NONE, // 122 key_hangeul
	PS2_NONE, // 123 key_hanja
	PS2_NONE, // 124 key_yen
	 EXT | 0x1f, // 125 key_leftmeta
	 EXT | 0x27, // 126 key_rightmeta
	PS2_NONE, // 127 key_compose
	PS2_NONE, // 128 key_stop
	PS2_NONE, // 129 key_again
	PS2_NONE, // 130 key_props
	PS2_NONE, // 131 key_undo
	PS2_NONE, // 132 key_front
	PS2_NONE, // 133 key_copy
	PS2_NONE, // 134 key_open
	PS2_NONE, // 135 key_paste
	PS2_NONE, // 136 key_find
	PS2_NONE, // 137 key_cut
	PS2_NONE, // 138 key_help
	PS2_NONE, // 139 key_menu
	PS2_NONE, // 140 key_calc
	PS2_NONE, // 141 key_setup
	PS2_NONE, // 142 key_sleep
	PS2_NONE, // 143 key_wakeup
	PS2_NONE, // 144 key_file
	PS2_NONE, // 145 key_sendfile
	PS2_NONE, // 146 key_deletefile
	PS2_NONE, // 147 key_xfer
	PS2_NONE, // 148 key_prog1
	PS2_NONE, // 149 key_prog2
	PS2_NONE, // 150 key_www
	PS2_NONE, // 151 key_msdos
	PS2_NONE, // 152 key_screenlock
	PS2_NONE, // 153 key_direction
	PS2_NONE, // 154 key_cyclewindows
	PS2_NONE, // 155 key_mail
	PS2_NONE, // 156 key_bookmarks
	PS2_NONE, // 157 key_computer
	PS2_NONE, // 158 key_back
	PS2_NONE, // 159 key_forward
	PS2_NONE, // 160 key_closecd
	PS2_NONE, // 161 key_ejectcd
	PS2_NONE, // 162 key_ejectclosecd
	PS2_NONE, // 163 key_nextsong
	PS2_NONE, // 164 key_playpause
	PS2_NONE, // 165 key_previoussong
	PS2_NONE, // 166 key_stopcd
	PS2_NONE, // 167 key_record
	PS2_NONE, // 168 key_rewind
	PS2_NONE, // 169 key_phone
	PS2_NONE, // 170 key_iso
	PS2_NONE, // 171 key_config
	PS2_NONE, // 172 key_homepage
	PS2_NONE, // 173 key_refresh
	PS2_NONE, // 174 key_exit
	PS2_NONE, // 175 key_move
	PS2_NONE, // 176 key_edit
	PS2_NONE, // 177 key_scrollup
	PS2_NONE, // 178 key_scrolldown
	PS2_NONE, // 179 key_kpleftparen
	PS2_NONE, // 180 key_kprightparen
	PS2_NONE, // 181 key_new
	PS2_NONE, // 182 key_redo
	PS2_NONE, // 183 key_f13
	PS2_NONE, // 184 key_f14
	PS2_NONE, // 185 key_f15
	PS2_NONE, // 186 key_f16
	EMU_SWITCH_1 | 1, // 187 key_f17
	EMU_SWITCH_1 | 2, // 188 key_f18
	EMU_SWITCH_1 | 3, // 189 key_f19
	EMU_SWITCH_1 | 4, // 190 key_f20
	PS2_NONE, // 191 key_f21
	PS2_NONE, // 192 key_f22
	PS2_NONE, // 193 key_f23
	0x5D, // 194 u-mlaut on de mapped to backslash
	PS2_NONE, // 195 ???
	PS2_NONE, // 196 ???
	PS2_NONE, // 197 ???
	PS2_NONE, // 198 ???
	PS2_NONE, // 199 ???
	EXT | 0x75, // 200 key_up
	PS2_NONE, // 201 ???
	PS2_NONE, // 202 ???
	EXT | 0x6b, // 203 key_left
	PS2_NONE, // 204 ???
	EXT | 0x74, // 205 key_right
	PS2_NONE, // 206 ???
	PS2_NONE, // 207 ???
	EXT | 0x72, // 208 key_down
	PS2_NONE, // 209 ???
	PS2_NONE, // 210 ???
	PS2_NONE, // 211 ???
	PS2_NONE, // 212 ???
	PS2_NONE, // 213 ???
	PS2_NONE, // 214 ???
	PS2_NONE, // 215 ???
	PS2_NONE, // 216 ???
	PS2_NONE, // 217 ???
	PS2_NONE, // 218 ???
	PS2_NONE, // 219 ???
	PS2_NONE, // 220 ???
	PS2_NONE, // 221 ???
	PS2_NONE, // 222 ???
	PS2_NONE, // 223 ???
	PS2_NONE, // 224 ???
	PS2_NONE, // 225 ???
	PS2_NONE, // 226 ???
	PS2_NONE, // 227 ???
	PS2_NONE, // 228 ???
	PS2_NONE, // 229 ???
	PS2_NONE, // 230 ???
	PS2_NONE, // 231 ???
	PS2_NONE, // 232 ???
	PS2_NONE, // 233 ???
	PS2_NONE, // 234 ???
	PS2_NONE, // 235 ???
	PS2_NONE, // 236 ???
	PS2_NONE, // 237 ???
	PS2_NONE, // 238 ???
	PS2_NONE, // 239 ???
	PS2_NONE, // 240 ???
	PS2_NONE, // 241 ???
	PS2_NONE, // 242 ???
	PS2_NONE, // 243 ???
	PS2_NONE, // 244 ???
	PS2_NONE, // 245 ???
	PS2_NONE, // 246 ???
	PS2_NONE, // 247 ???
	PS2_NONE, // 248 ???
	PS2_NONE, // 249 ???
	PS2_NONE, // 250 ???
	PS2_NONE, // 251 ???
	PS2_NONE, // 252 ???
	PS2_NONE, // 253 ???
	PS2_NONE, // 254 ???
	PS2_NONE  // 255 ???
};
#else
static const int ev2ps2[] =
{
	PS2_NONE, // 0   key_reserved
	PS2_NONE, // 1   key_reserved
	PS2_NONE, // 2   key_reserved
	PS2_NONE, // 3   key_reserved
	0x1c, // 4  key_a
	0x32, // 5  key_b
	0x21, // 6  key_c
	0x23, // 7  key_d
	0x24, // 8  key_e
	0x2b, // 9  key_f
	0x34, // 10  key_g
	0x33, // 11  key_h
	0x43, // 12  key_i
	0x3b, // 13  key_j
	0x42, // 14  key_k
	0x4b, // 15  key_l
	0x3a, // 16  key_m
	0x31, // 17  key_n
	0x44, // 18  key_o
	0x4d, // 19  key_p
	0x15, // 20  key_q
	0x2d, // 21  key_r
	0x1b, // 22  key_s
	0x2c, // 23  key_t
	0x3c, // 24  key_u
	0x2a, // 25  key_v
	0x1d, // 26  key_w
	0x22, // 27  key_x
	0x35, // 28  key_y
	0x1a, // 29  key_z
	0x16, // 30   key_1
	0x1e, // 31   key_2
	0x26, // 32  key_3
	0x25, // 33  key_4
	0x2e, // 34  key_5
	0x36, // 35  key_6
	0x3d, // 36  key_7
	0x3e, // 37  key_8
	0x46, // 38  key_9
	0x45, // 39  key_0
	0x5a, // 40  key_enter
	0x76, // 41  key_esc
	0x66, // 42  key_backspace
	0x0d, // 43  key_tab
	0x29, // 44  key_space
	0x4e, // 45  key_minus
	0x55, // 46  key_equal
	0x54, // 47  key_leftbrace
	0x5b, // 48  key_rightbrace
	0x5d, // 49  key_backslash
	PS2_NONE, // 50  key_reserved
	0x4c, // 51  key_semicolon
	0x52, // 52  key_apostrophe
	0x0e, // 53  key_grave
	0x41, // 54  key_comma
	0x49, // 55  key_dot
	0x4a, // 56  key_slash
	0x58, // 57  key_capslock
	0x05, // 58  key_f1
	0x06, // 59  key_f2
	0x04, // 60  key_f3
	0x0c, // 61  key_f4
	0x03, // 62  key_f5
	0x0b, // 63  key_f6
	0x83, // 64  key_f7
	0x0a, // 65  key_f8
	0x01, // 66  key_f9
	0x09, // 67  key_f10
	0x78, // 68  key_f11
	0x07, // 69  key_f12
	PS2_NONE, // 70  key_print
	EMU_SWITCH_1 | 0x7E, // 71  key_scrolllock
	0xE1, // 72 key_pause
	EXT | 0x70, // 73  key_insert
	EXT | 0x6c, // 74  key_home
	EXT | 0x7d, // 75  key_pageup
	EXT | 0x71, // 76  key_delete
	EXT | 0x69, // 77  key_end
	EXT | 0x7a, // 78  key_pagedown
	EXT | 0x74, // 79  key_right
	EXT | 0x6b, // 80  key_left
	EXT | 0x72, // 81  key_down
	EXT | 0x75, // 82  key_up
	0x77, // 83  sdl_scancode_numlockclear  (mac keypad clear -> adb 0x47 via adb.v)
	EXT | 0x4a, // 84  key_kpslash
	0x7c, // 85  key_kpasterisk
	0x7b, // 86  key_kpminus
	0x79, // 87  key_kpplus
	EXT | 0x5a, // 88  key_kpenter
	0x69, // 89  key_kp1
	0x72, // 90  key_kp2
	0x7a, // 91  key_kp3
	0x6b, // 92  key_kp4
	0x73, // 93  key_kp5
	0x74, // 94  key_kp6
	0x6c, // 95  key_kp7
	0x75, // 96  key_kp8
	0x7d, // 97  key_kp9
	0x70, // 98  key_kp0
	0x71, // 99  key_kpdot
	0x61, // 100 sdl_scancode_nonusbackslash  (102nd key / iso <> between lshift and z)
	EXT | 0x27, // 101 sdl_scancode_application  (reuse ps/2 r-windows code -> option/closed apple)
	PS2_NONE, // 102 key_power
	0x0F, // 103 sdl_scancode_kp_equals  (numeric keypad =)
	PS2_NONE, // 104 key_f13
	PS2_NONE, // 105 key_f14
	PS2_NONE, // 106 key_f15
	PS2_NONE, // 107 key_f16
	EMU_SWITCH_1 | 1, // 108 key_f17
	EMU_SWITCH_1 | 2, // 109 key_f18
	EMU_SWITCH_1 | 3, // 110 key_f19
	EMU_SWITCH_1 | 4, // 111 key_f20
	PS2_NONE, // 112 key_f21
	PS2_NONE, // 113 key_f22
	PS2_NONE, // 114 key_f23
	PS2_NONE, // 115 key_f24
	PS2_NONE, // 116
	PS2_NONE, // 117 key_help
	PS2_NONE, // 118
	PS2_NONE, // 119
	PS2_NONE, // 120
	PS2_NONE, // 121
	PS2_NONE, // 122
	PS2_NONE, // 123
	PS2_NONE, // 124
	PS2_NONE, // 125
	PS2_NONE, // 126
	PS2_NONE, // 127
	PS2_NONE, // 128
	PS2_NONE, // 129
	PS2_NONE, // 130
	PS2_NONE, // 131
	PS2_NONE, // 132
	PS2_NONE, // 133
	PS2_NONE, // 134
	PS2_NONE, // 135
	PS2_NONE, // 136
	PS2_NONE, // 137
	PS2_NONE, // 138
	PS2_NONE, // 139
	PS2_NONE, // 140
	PS2_NONE, // 141
	PS2_NONE, // 142
	PS2_NONE, // 143
	PS2_NONE, // 144
	PS2_NONE, // 145
	PS2_NONE, // 146
	PS2_NONE, // 147
	PS2_NONE, // 148
	PS2_NONE, // 149
	PS2_NONE, // 150
	PS2_NONE, // 151
	PS2_NONE, // 152
	PS2_NONE, // 153
	PS2_NONE, // 154
	PS2_NONE, // 155
	PS2_NONE, // 156
	PS2_NONE, // 157
	PS2_NONE, // 158
	PS2_NONE, // 159
	PS2_NONE, // 160
	PS2_NONE, // 161
	PS2_NONE, // 162
	PS2_NONE, // 163
	PS2_NONE, // 164
	PS2_NONE, // 165
	PS2_NONE, // 166
	PS2_NONE, // 167
	PS2_NONE, // 168
	PS2_NONE, // 169
	PS2_NONE, // 170
	PS2_NONE, // 171
	PS2_NONE, // 172
	PS2_NONE, // 173
	PS2_NONE, // 174
	PS2_NONE, // 175
	PS2_NONE, // 176
	PS2_NONE, // 177
	PS2_NONE, // 178
	PS2_NONE, // 179
	PS2_NONE, // 180
	PS2_NONE, // 181
	PS2_NONE, // 182
	PS2_NONE, // 183
	PS2_NONE, // 184
	PS2_NONE, // 185
	PS2_NONE, // 186
	PS2_NONE, // 187
	PS2_NONE, // 188
	PS2_NONE, // 189
	PS2_NONE, // 180
	PS2_NONE, // 191
	PS2_NONE, // 192
	PS2_NONE, // 193
	PS2_NONE, // 194
	PS2_NONE, // 195
	PS2_NONE, // 196
	PS2_NONE, // 197
	PS2_NONE, // 198
	PS2_NONE, // 109
	PS2_NONE, // 200
	PS2_NONE, // 201
	PS2_NONE, // 202
	PS2_NONE, // 203
	PS2_NONE, // 204
	PS2_NONE, // 205
	PS2_NONE, // 206
	PS2_NONE, // 207
	PS2_NONE, // 208
	PS2_NONE, // 209
	PS2_NONE, // 210
	PS2_NONE, // 211
	PS2_NONE, // 212
	PS2_NONE, // 213
	PS2_NONE, // 214
	PS2_NONE, // 215
	PS2_NONE, // 216
	PS2_NONE, // 217
	PS2_NONE, // 218
	PS2_NONE, // 219
	PS2_NONE, // 220
	PS2_NONE, // 221
	PS2_NONE, // 222
	PS2_NONE, // 223
	 0x14, // 224  sdl_scancode_lctrl
	 0x12, // 225  sdl_scancode_lshift
	 0x11, // 226  sdl_scancode_lalt  (open apple / command)
	 EXT | 0x1F, // 227  sdl_scancode_lgui  (mac ⌘, win key) -> closed apple / option
	 EXT | 0x14, // 228  sdl_scancode_rctrl
	 0x59, // 229  sdl_scancode_rshift
	 EXT | 0x11, // 230  sdl_scancode_ralt
	 EXT | 0x27, // 231  sdl_scancode_rgui  (rightgui) -> closed apple / option (menu key ps/2 code)

};
/* http://www-personal.umich.edu/~bazald/l/api/_s_d_l__scancode_8h.html */
#endif
bool ReadKeyboard()
{
#ifdef WIN32
	HRESULT result;

	result = m_keyboard->GetDeviceState(sizeof(m_keyboardState), (LPVOID)&m_keyboardState);
	if (FAILED(result))
	{
		if ((result == DIERR_INPUTLOST) || (result == DIERR_NOTACQUIRED)) { m_keyboard->Acquire(); }
		else { return false; }
	}
#else
	if (headless) {
		m_keyboardStateCount = 0;
		m_keyboardState = nullptr;
		return true;
	}
	m_keyboardState = SDL_GetKeyboardState(&m_keyboardStateCount);
	if (!m_keyboardState_last) m_keyboardState_last = (Uint8*)calloc(m_keyboardStateCount, sizeof(Uint8));
#endif

	return true;
}

int SimInput::Initialise() {

#ifdef WIN32
	m_directInput = 0;
	m_keyboard = 0;
	HRESULT result;
	result = DirectInput8Create(GetModuleHandle(nullptr), DIRECTINPUT_VERSION, IID_IDirectInput8, (void**)&m_directInput, NULL);
	if (FAILED(result)) { return false; }
	result = m_directInput->CreateDevice(GUID_SysKeyboard, &m_keyboard, NULL);
	if (FAILED(result)) { return false; }
	result = m_keyboard->SetDataFormat(&c_dfDIKeyboard);
	if (FAILED(result)) { return false; }
	result = m_keyboard->Acquire();
	if (FAILED(result)) { return false; }
#endif
	return 0;
}

void SimInput::Read() {
	bool pr = ReadKeyboard();

	for (int i = 0; i < inputCount; i++) {
#ifdef WIN32
		inputs[i] = m_keyboardState[mappings[i]] & 0x80;
#else
		inputs[i] = headless ? 0 : m_keyboardState[mappings[i]];
#endif
	}

#ifdef WIN32
	for (unsigned char k = 0; k < 220; k++) {

		if (m_keyboardState_last[k] != m_keyboardState[k]) {
			unsigned int ext = ev2ps2[k] & EXT;
			SimInput_PS2KeyEvent evt = SimInput_PS2KeyEvent(k, m_keyboardState[k], ext, ev2ps2[k]);
			keyEvents.push(evt);
		}
		m_keyboardState_last[k] = m_keyboardState[k];
	}
#else
	if (!headless) {
		// macos caps lock scancode is transient, use sdl modifier transitions
		// emit one ps/2 key-down per toggle
		static int caps_mod_last = -1;
		int caps_mod_now = (SDL_GetModState() & KMOD_CAPS) ? 1 : 0;
		if (caps_mod_last == -1) caps_mod_last = caps_mod_now;
		if (caps_mod_last != caps_mod_now) {
			const unsigned int CAPSLOCK_PS2 = 0x58;
			SimInput_PS2KeyEvent evt(57, true, false, CAPSLOCK_PS2);
			keyEvents.push(evt);
			caps_mod_last = caps_mod_now;
			if (m_keyboardState_last && m_keyboardStateCount > 57) {
				m_keyboardState_last[57] = caps_mod_now;
			}
		}
		for (int k = 0; k < m_keyboardStateCount; k++) {
			if (m_keyboardState_last[k] != m_keyboardState[k]) {
				if (k == 57) {
					m_keyboardState_last[k] = m_keyboardState[k];
					continue;
				}
				unsigned int mapped = ev2ps2[k];
				bool ext = (mapped & EXT) != 0;
				SimInput_PS2KeyEvent evt = SimInput_PS2KeyEvent(k, m_keyboardState[k], ext, mapped);
				keyEvents.push(evt);
			}
			m_keyboardState_last[k] = m_keyboardState[k];
		}
	}
#endif

}

void SimInput::SetMapping(int index, int code) {
	if (code < 256)
		mappings[index] = code;
	else
		mappings[index] = 0;
}

void SimInput::CleanUp() {

#ifdef WIN32
	if (m_keyboard) { m_keyboard->Unacquire(); m_keyboard->Release(); m_keyboard = 0; }
	if (m_directInput) { m_directInput->Release(); m_directInput = 0; }
#endif
}

unsigned int ps2_key_temp;
bool ps2_clock = 1;


void SimInput::BeforeEval()
{
	if (keyEventTimer == 0) {

		if (keyEvents.size() > 0) {
			SimInput_PS2KeyEvent evt = keyEvents.front();
			keyEvents.pop();

			ps2_key_temp = evt.mapped;

			if (evt.extended) { ps2_key_temp |= (1UL << 8); }
			if (evt.pressed) { ps2_key_temp |= (1UL << 9); }
			if (ps2_clock) { ps2_key_temp |= (1UL << 10); }

			ps2_clock = !ps2_clock;

			*ps2_key = ps2_key_temp;

			keyEventTimer = keyEventWait;
		}
	}
	else {
		keyEventTimer--;
	}
}

SimInput::SimInput(int count, DebugConsole c)
{
	inputCount = count;
	console = c;
}

SimInput::~SimInput()
{

}
