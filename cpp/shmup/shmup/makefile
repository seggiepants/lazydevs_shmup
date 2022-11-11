OBJS = Enemy.o \
	Input.o \
	Particle.o \
	Scene.o \
	SceneStart.o \
	Shockwave.o \
	Sprite.o \
	Star.o \
	Starfield.o \
	common.o \
	draw.o \
	game.o \
	main.o \
	jsoncpp.o
CFLAGS = -Wall -g
CC = g++
INCLUDES = -I ~/Documents/code/raylib/src -I .
LIBS = -lm -lraylib -lpthread -lGL -ldl

shmup: ${OBJS}
	${CC} ${CFLAGS} ${INCLUDES} -o $@ ${OBJS} ${LIBS}

clean:
	-rm -f  *.o core *.core

.cpp.o:
	${CC} ${CFLAGS} ${INCLUDES} -c $<

