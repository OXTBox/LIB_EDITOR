#!/usr/bin/env python3
"""make_card_maps.py - writes the small maps the editor cards E03-E15 use (LIB_EDITOR/maps).

    python3 -I tools/make_card_maps.py

cards_yard.cellmap   a west room and an east room (version 2): the @ start, two doors (+),
                     a pressure plate and an anti plate linked to the south door, a teleporter
                     pair, a stepped pool (deep water), a monster spawner, three camera squares,
                     a ~ tunnel without a roof yet. E04-E11 and E15 use it; E12 finds no problem in it.
cards_broken.cellmap a map with a problem of every kind the checker (E12) knows.
Written through LIB_BIT/editor/python/cellmap.py, so the files are exactly what the libraries write.
"""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', 'LIB_BIT', 'editor', 'python'))
import cellmap as cm  # noqa: E402

YARD = [
    '##############',
    '#.T....#...M.#',
    '#......#.....#',
    '#......#.}}}.#',
    '#.@....+.}}}.#',
    '#......#.}}}.#',
    '#......#.....#',
    '#..p...+.p...#',
    '#.~~~~.#....T#',
    '##############',
]

BROKEN = [
    '##########',
    '#....#..##',
    '#....#..##',
    '#....####.',
    '#.T......#',
    '#........#',
    '##########',
]


def build(rows, name):
    m = cm.new_map2(len(rows[0]), len(rows), name=name, wallH=62)
    for r, line in enumerate(rows):
        for c, ch in enumerate(line):
            m['tags'][r][c] = ch
            m['design'][r][c] = ord(ch)
            m['floor'][r][c] = 100 if ch == '#' else 1
            if ch == '+':                     # a closed door: solid from the floor to the roof top (101)
                m['ceiling'][r][c] = 1
                m['green'][r][c] = 100
    return m


def yard():
    m = build(YARD, 'cards_yard')
    for r in (3, 4, 5):                       # the pool steps down east: 20, 40, 60 hu deep
        for c, deep in ((9, 20), (10, 40), (11, 60)):
            m['red'][r][c] = deep
    m['links'] = [
        dict(**{'from': '4,8', 'type': 'pad', 'to': '8,8', 'note': 'the plate opens the south door'}),
        dict(**{'from': '10,8', 'type': 'anti', 'to': '8,8', 'note': 'this plate shuts it again'}),
        dict(**{'from': '3,2', 'type': 'teleport', 'to': '13,9', 'note': 'west teleporter to the east room'}),
        dict(**{'from': '13,9', 'type': 'teleport', 'to': '3,2', 'note': 'and back'}),
        dict(**{'from': '10,7', 'type': 'camera', 'to': '@cam1', 'note': 'the pool camera'}),
        dict(**{'from': '11,7', 'type': 'camera', 'to': '@cam1', 'note': 'the pool camera'}),
        dict(**{'from': '12,7', 'type': 'camera', 'to': '@cam1', 'note': 'the pool camera'}),
        dict(**{'from': '5,3', 'type': 'camera', 'to': '@cam2', 'note': 'the corner camera watches you'}),
        dict(**{'from': '3,9', 'type': 'camera', 'to': '@cam3', 'note': 'a flyby of the yard'}),
    ]
    m['objects'] = [
        dict(id='sp1', kind='spawner', at='12,2', facing=180, above=0,
             props='what=orb;initial=2;min=1;max=4;chance=25;every=30;spread=2'),
        dict(id='cam1', kind='camera', at='13.4,3', facing=225, above=180, props='mode=fixed;pitch=40'),
        dict(id='cam2', kind='camera', at='1.6,1.6', facing=135, above=220, props='mode=target'),
        dict(id='cam3', kind='camera', at='2,2', facing=90, above=260,
             props='mode=flyby;path=2,2 13,2 13,9 2,9;steps=120'),
    ]
    return m


def broken():
    m = build(BROKEN, 'cards_broken')
    m['floor'][3][9] = 0                      # 10,4: empty space at the edge (a slope on it does nothing)
    m['ceiling'][5][6] = 90                   # 7,6: a low roof the slope pokes through
    m['links'] = [
        dict(**{'from': '4,5', 'type': 'pad', 'to': '12,3', 'note': 'a door that is not on the map'}),
        dict(**{'from': '2,2', 'type': 'camera', 'to': '@cam9', 'note': 'a camera nobody placed'}),
        dict(**{'from': '3,5', 'type': 'teleport', 'to': '', 'note': 'a teleporter to nowhere'}),
    ]
    m['meta']['version'] = 3
    m['slope'] = {
        (4, 1): [10, 10, 20, 10],            # 2,5: all four corners lifted
        (3, 9): [0, 0, 30, 30],              # 10,4: a slope on empty space
        (5, 1): [0, 90, 90, 0],              # 2,6: steep, its low (west) edge against the wall: a trap
        (5, 6): [0, 0, 0, 95],               # 7,6: pokes through its roof (90)
    }
    return m


if __name__ == '__main__':
    out = os.path.join(HERE, '..', 'maps')
    os.makedirs(out, exist_ok=True)
    for m in (yard(), broken()):
        p = os.path.join(out, m['meta']['name'] + '.cellmap')
        cm.write_map(m, p)
        print('wrote', os.path.relpath(p, os.path.join(HERE, '..')))
