#include "OutnumberedHost.h"
#include <SDL3/SDL.h>
#include <string.h>
static SDL_Window *window;
static SDL_Renderer *renderer;
static SDL_Texture *texture;
static SDL_AudioStream *sound;
static Uint64 sound_end;
int ow_open(void) {
    if (!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)) return 0;
    if (!SDL_CreateWindowAndRenderer("Outnumbered!",960,600,SDL_WINDOW_RESIZABLE | SDL_WINDOW_HIGH_PIXEL_DENSITY,&window,&renderer)) return 0;
    SDL_SetRenderLogicalPresentation(renderer,320,200,SDL_LOGICAL_PRESENTATION_LETTERBOX);
    texture=SDL_CreateTexture(renderer,SDL_PIXELFORMAT_RGBA32,SDL_TEXTUREACCESS_STREAMING,320,200);
    if (!texture) return 0;
    SDL_SetTextureScaleMode(texture,SDL_SCALEMODE_NEAREST);
    SDL_StartTextInput(window);
    return 1;
}
static uint16_t logical_key(SDL_Scancode s) {
    switch(s) {
        case SDL_SCANCODE_LEFT:return 123;case SDL_SCANCODE_RIGHT:return 124;
        case SDL_SCANCODE_UP:return 126;case SDL_SCANCODE_DOWN:return 125;
        case SDL_SCANCODE_SPACE:return 49;case SDL_SCANCODE_RETURN:return 36;
        case SDL_SCANCODE_KP_ENTER:return 76;case SDL_SCANCODE_ESCAPE:return 53;
        case SDL_SCANCODE_TAB:return 48;case SDL_SCANCODE_BACKSPACE:return 51;
        case SDL_SCANCODE_DELETE:return 117;case SDL_SCANCODE_HOME:return 115;
        case SDL_SCANCODE_PAGEUP:return 116;case SDL_SCANCODE_F12:return 111;
        case SDL_SCANCODE_F1:return 122;case SDL_SCANCODE_F2:return 120;
        case SDL_SCANCODE_F3:return 99;default:return 65535;
    }
}
int ow_poll(OWEvent *out) {
    SDL_Event e;
    while(SDL_PollEvent(&e)) {
        memset(out,0,sizeof(*out));
        if(e.type==SDL_EVENT_QUIT) {out->type=1;return 1;}
        if(e.type==SDL_EVENT_WINDOW_FOCUS_LOST) {out->type=5;return 1;}
        if(e.type==SDL_EVENT_MOUSE_BUTTON_DOWN && e.button.button==SDL_BUTTON_LEFT) {
            out->type=4;SDL_RenderCoordinatesFromWindow(renderer,e.button.x,e.button.y,&out->x,&out->y);return 1;
        }
        if(e.type==SDL_EVENT_TEXT_INPUT) {out->type=2;out->key=65535;SDL_strlcpy(out->text,e.text.text,sizeof(out->text));return 1;}
        if(e.type==SDL_EVENT_KEY_DOWN || e.type==SDL_EVENT_KEY_UP) {
            out->key=logical_key(e.key.scancode);out->repeat=e.key.repeat;
            SDL_Keymod m=e.key.mod;
            out->modifiers=((m&SDL_KMOD_SHIFT)?1:0)|((m&SDL_KMOD_CTRL)?2:0)|((m&SDL_KMOD_GUI)?4:0)|((m&SDL_KMOD_ALT)?8:0);
            // Printable characters arrive through Unicode text input, not twice.
            if(out->key==65535 && !(m&(SDL_KMOD_CTRL|SDL_KMOD_ALT))) continue;
            out->type=e.type==SDL_EVENT_KEY_DOWN?2:3;
            if(e.key.key>=32 && e.key.key<127) {out->text[0]=(char)e.key.key;out->text[1]=0;}
            return 1;
        }
    }
    return 0;
}
void ow_frame(const uint8_t *rgba) {
    SDL_UpdateTexture(texture,0,rgba,320*4);SDL_SetRenderDrawColor(renderer,0,0,0,255);
    SDL_RenderClear(renderer);SDL_RenderTexture(renderer,texture,0,0);SDL_RenderPresent(renderer);
}
void ow_stop_sound(void) {if(sound) SDL_DestroyAudioStream(sound);sound=0;sound_end=0;}
int ow_sound(const char *path) {
    ow_stop_sound();SDL_AudioSpec spec;Uint8 *bytes=0;Uint32 count=0;
    if(!SDL_LoadWAV(path,&spec,&bytes,&count)) return 0;
    sound=SDL_OpenAudioDeviceStream(SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK,&spec,0,0);
    if(!sound) {SDL_free(bytes);return 0;}
    int success=SDL_PutAudioStreamData(sound,bytes,count) && SDL_FlushAudioStream(sound) && SDL_ResumeAudioStreamDevice(sound);
    sound_end=SDL_GetTicksNS()+(Uint64)((double)count/(spec.freq*SDL_AUDIO_BYTESIZE(spec.format)*spec.channels)*1000000000.0);
    SDL_free(bytes);return success;
}
int ow_sound_playing(void) {return sound && (SDL_GetAudioStreamQueued(sound)>0 || SDL_GetTicksNS()<sound_end);}
void ow_error(const char *message) {SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR,"Outnumbered",message,window);}
int ow_choose_member(const char *name) {
    const SDL_MessageBoxButtonData buttons[]={{SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT,1,"Restore"},{0,2,"Next member"},{SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT,3,"Cancel"}};
    SDL_MessageBoxData data={SDL_MESSAGEBOX_INFORMATION,window,"Restore Removed Member",name,3,buttons,0};int choice=3;
    SDL_ShowMessageBox(&data,&choice);return choice;
}
void ow_delay(void) {SDL_Delay(1);}
void ow_close(void) {ow_stop_sound();SDL_DestroyTexture(texture);SDL_DestroyRenderer(renderer);SDL_DestroyWindow(window);SDL_Quit();}
