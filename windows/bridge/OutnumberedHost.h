#pragma once
#include <stdint.h>
typedef struct OWEvent { int type; uint16_t key; int repeat; int modifiers; float x,y; char text[64]; } OWEvent;
int ow_open(void);
int ow_poll(OWEvent *event);
void ow_frame(const uint8_t *rgba);
void ow_close(void);
void ow_delay(void);
int ow_sound(const char *path);
int ow_sound_at(const char *path,double seconds);
void ow_stop_sound(void);
int ow_sound_playing(void);
void ow_error(const char *message);
int ow_choose_member(const char *name);
