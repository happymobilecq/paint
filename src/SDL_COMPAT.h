//
//  SDL_COMPAT.h
//  Tuxpaint
//
//  Created by dev on 14-11-17.
//  Copyright (c) 2014年 happymobile. All rights reserved.
//

#ifndef Tuxpaint_SDL_COMPAT_h
#define Tuxpaint_SDL_COMPAT_h
#include "SDL.h"
#if SDL_MAJOR_VERSION >=2
#define SDL_SRCALPHA 1
static int SDL_SetAlpha(SDL_Surface *surface, Uint32 flag, Uint8 alpha)
{
    if (flag & SDL_RLEACCEL) {
        SDL_SetSurfaceRLE(surface, 1);
    }
    
    if (flag & SDL_SRCALPHA) {
        SDL_SetSurfaceBlendMode(surface, SDL_BLENDMODE_BLEND);
    }
    return SDL_SetSurfaceAlphaMod(surface, alpha);
}
static int SDL_EnableUNICODE(int enable)
{
    static int state;
    int old = state;
    state = enable;
    return old;
}
#endif

#endif
