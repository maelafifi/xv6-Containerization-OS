
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 30 e9 10 80       	mov    $0x8010e930,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 ee 3a 10 80       	mov    $0x80103aee,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 d4 98 10 	movl   $0x801098d4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100049:	e8 30 54 00 00       	call   8010547e <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 8c 30 11 80 3c 	movl   $0x8011303c,0x8011308c
80100055:	30 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 90 30 11 80 3c 	movl   $0x8011303c,0x80113090
8010005f:	30 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 74 e9 10 80 	movl   $0x8010e974,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 90 30 11 80    	mov    0x80113090,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 3c 30 11 80 	movl   $0x8011303c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 db 98 10 	movl   $0x801098db,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 a9 52 00 00       	call   80105340 <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 90 30 11 80       	mov    0x80113090,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 90 30 11 80       	mov    %eax,0x80113090

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 3c 30 11 80 	cmpl   $0x8011303c,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
801000c9:	e8 d1 53 00 00       	call   8010549f <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 90 30 11 80       	mov    0x80113090,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100104:	e8 00 54 00 00       	call   80105509 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 63 52 00 00       	call   8010537a <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 3c 30 11 80 	cmpl   $0x8011303c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 8c 30 11 80       	mov    0x8011308c,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
8010017d:	e8 87 53 00 00       	call   80105509 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 ea 51 00 00       	call   8010537a <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 3c 30 11 80 	cmpl   $0x8011303c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 e2 98 10 80 	movl   $0x801098e2,(%esp)
801001ae:	e8 a1 03 00 00       	call   80100554 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 36 29 00 00       	call   80102b1d <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 17 52 00 00       	call   80105417 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 f3 98 10 80 	movl   $0x801098f3,(%esp)
8010020b:	e8 44 03 00 00       	call   80100554 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 f3 28 00 00       	call   80102b1d <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 d7 51 00 00       	call   80105417 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 fa 98 10 80 	movl   $0x801098fa,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 77 51 00 00       	call   801053d5 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100265:	e8 35 52 00 00       	call   8010549f <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 90 30 11 80    	mov    0x80113090,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 3c 30 11 80 	movl   $0x8011303c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 90 30 11 80       	mov    0x80113090,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 90 30 11 80       	mov    %eax,0x80113090
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
801002d1:	e8 33 52 00 00       	call   80105509 <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801002e8:	89 c2                	mov    %eax,%edx
801002ea:	ec                   	in     (%dx),%al
801002eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801002f1:	c9                   	leave  
801002f2:	c3                   	ret    

801002f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f3:	55                   	push   %ebp
801002f4:	89 e5                	mov    %esp,%ebp
801002f6:	83 ec 08             	sub    $0x8,%esp
801002f9:	8b 45 08             	mov    0x8(%ebp),%eax
801002fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801002ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100303:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100306:	8a 45 f8             	mov    -0x8(%ebp),%al
80100309:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100312:	fa                   	cli    
}
80100313:	5d                   	pop    %ebp
80100314:	c3                   	ret    

80100315 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100315:	55                   	push   %ebp
80100316:	89 e5                	mov    %esp,%ebp
80100318:	56                   	push   %esi
80100319:	53                   	push   %ebx
8010031a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100321:	74 1c                	je     8010033f <printint+0x2a>
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	c1 e8 1f             	shr    $0x1f,%eax
80100329:	0f b6 c0             	movzbl %al,%eax
8010032c:	89 45 10             	mov    %eax,0x10(%ebp)
8010032f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100333:	74 0a                	je     8010033f <printint+0x2a>
    x = -xx;
80100335:	8b 45 08             	mov    0x8(%ebp),%eax
80100338:	f7 d8                	neg    %eax
8010033a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033d:	eb 06                	jmp    80100345 <printint+0x30>
  else
    x = xx;
8010033f:	8b 45 08             	mov    0x8(%ebp),%eax
80100342:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034f:	8d 41 01             	lea    0x1(%ecx),%eax
80100352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 f3                	div    %ebx
80100362:	89 d0                	mov    %edx,%eax
80100364:	8a 80 08 b0 10 80    	mov    -0x7fef4ff8(%eax),%al
8010036a:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036e:	8b 75 0c             	mov    0xc(%ebp),%esi
80100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100374:	ba 00 00 00 00       	mov    $0x0,%edx
80100379:	f7 f6                	div    %esi
8010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100382:	75 c8                	jne    8010034c <printint+0x37>

  if(sign)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 10                	je     8010039a <printint+0x85>
    buf[i++] = '-';
8010038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038d:	8d 50 01             	lea    0x1(%eax),%edx
80100390:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100393:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100398:	eb 17                	jmp    801003b1 <printint+0x9c>
8010039a:	eb 15                	jmp    801003b1 <printint+0x9c>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	8a 00                	mov    (%eax),%al
801003a6:	0f be c0             	movsbl %al,%eax
801003a9:	89 04 24             	mov    %eax,(%esp)
801003ac:	e8 b7 03 00 00       	call   80100768 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b1:	ff 4d f4             	decl   -0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 e2                	jns    8010039c <printint+0x87>
    consputc(buf[i]);
}
801003ba:	83 c4 30             	add    $0x30,%esp
801003bd:	5b                   	pop    %ebx
801003be:	5e                   	pop    %esi
801003bf:	5d                   	pop    %ebp
801003c0:	c3                   	ret    

801003c1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c1:	55                   	push   %ebp
801003c2:	89 e5                	mov    %esp,%ebp
801003c4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c7:	a1 d4 d8 10 80       	mov    0x8010d8d4,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
801003dc:	e8 be 50 00 00       	call   8010549f <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 01 99 10 80 	movl   $0x80109901,(%esp)
801003ef:	e8 60 01 00 00       	call   80100554 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100401:	e9 1b 01 00 00       	jmp    80100521 <cprintf+0x160>
    if(c != '%'){
80100406:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040a:	74 10                	je     8010041c <cprintf+0x5b>
      consputc(c);
8010040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010040f:	89 04 24             	mov    %eax,(%esp)
80100412:	e8 51 03 00 00       	call   80100768 <consputc>
      continue;
80100417:	e9 02 01 00 00       	jmp    8010051e <cprintf+0x15d>
    }
    c = fmt[++i] & 0xff;
8010041c:	8b 55 08             	mov    0x8(%ebp),%edx
8010041f:	ff 45 f4             	incl   -0xc(%ebp)
80100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100425:	01 d0                	add    %edx,%eax
80100427:	8a 00                	mov    (%eax),%al
80100429:	0f be c0             	movsbl %al,%eax
8010042c:	25 ff 00 00 00       	and    $0xff,%eax
80100431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100438:	75 05                	jne    8010043f <cprintf+0x7e>
      break;
8010043a:	e9 01 01 00 00       	jmp    80100540 <cprintf+0x17f>
    switch(c){
8010043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100442:	83 f8 70             	cmp    $0x70,%eax
80100445:	74 4f                	je     80100496 <cprintf+0xd5>
80100447:	83 f8 70             	cmp    $0x70,%eax
8010044a:	7f 13                	jg     8010045f <cprintf+0x9e>
8010044c:	83 f8 25             	cmp    $0x25,%eax
8010044f:	0f 84 a3 00 00 00    	je     801004f8 <cprintf+0x137>
80100455:	83 f8 64             	cmp    $0x64,%eax
80100458:	74 14                	je     8010046e <cprintf+0xad>
8010045a:	e9 a7 00 00 00       	jmp    80100506 <cprintf+0x145>
8010045f:	83 f8 73             	cmp    $0x73,%eax
80100462:	74 57                	je     801004bb <cprintf+0xfa>
80100464:	83 f8 78             	cmp    $0x78,%eax
80100467:	74 2d                	je     80100496 <cprintf+0xd5>
80100469:	e9 98 00 00 00       	jmp    80100506 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
8010046e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100471:	8d 50 04             	lea    0x4(%eax),%edx
80100474:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100477:	8b 00                	mov    (%eax),%eax
80100479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100480:	00 
80100481:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100488:	00 
80100489:	89 04 24             	mov    %eax,(%esp)
8010048c:	e8 84 fe ff ff       	call   80100315 <printint>
      break;
80100491:	e9 88 00 00 00       	jmp    8010051e <cprintf+0x15d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004a8:	00 
801004a9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b0:	00 
801004b1:	89 04 24             	mov    %eax,(%esp)
801004b4:	e8 5c fe ff ff       	call   80100315 <printint>
      break;
801004b9:	eb 63                	jmp    8010051e <cprintf+0x15d>
    case 's':
      if((s = (char*)*argp++) == 0)
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cd:	75 09                	jne    801004d8 <cprintf+0x117>
        s = "(null)";
801004cf:	c7 45 ec 0a 99 10 80 	movl   $0x8010990a,-0x14(%ebp)
      for(; *s; s++)
801004d6:	eb 15                	jmp    801004ed <cprintf+0x12c>
801004d8:	eb 13                	jmp    801004ed <cprintf+0x12c>
        consputc(*s);
801004da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dd:	8a 00                	mov    (%eax),%al
801004df:	0f be c0             	movsbl %al,%eax
801004e2:	89 04 24             	mov    %eax,(%esp)
801004e5:	e8 7e 02 00 00       	call   80100768 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004ea:	ff 45 ec             	incl   -0x14(%ebp)
801004ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f0:	8a 00                	mov    (%eax),%al
801004f2:	84 c0                	test   %al,%al
801004f4:	75 e4                	jne    801004da <cprintf+0x119>
        consputc(*s);
      break;
801004f6:	eb 26                	jmp    8010051e <cprintf+0x15d>
    case '%':
      consputc('%');
801004f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ff:	e8 64 02 00 00       	call   80100768 <consputc>
      break;
80100504:	eb 18                	jmp    8010051e <cprintf+0x15d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100506:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050d:	e8 56 02 00 00       	call   80100768 <consputc>
      consputc(c);
80100512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100515:	89 04 24             	mov    %eax,(%esp)
80100518:	e8 4b 02 00 00       	call   80100768 <consputc>
      break;
8010051d:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010051e:	ff 45 f4             	incl   -0xc(%ebp)
80100521:	8b 55 08             	mov    0x8(%ebp),%edx
80100524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100527:	01 d0                	add    %edx,%eax
80100529:	8a 00                	mov    (%eax),%al
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	25 ff 00 00 00       	and    $0xff,%eax
80100533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053a:	0f 85 c6 fe ff ff    	jne    80100406 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100544:	74 0c                	je     80100552 <cprintf+0x191>
    release(&cons.lock);
80100546:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
8010054d:	e8 b7 4f 00 00       	call   80105509 <release>
}
80100552:	c9                   	leave  
80100553:	c3                   	ret    

80100554 <panic>:

void
panic(char *s)
{
80100554:	55                   	push   %ebp
80100555:	89 e5                	mov    %esp,%ebp
80100557:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
8010055a:	e8 b0 fd ff ff       	call   8010030f <cli>
  cons.locking = 0;
8010055f:	c7 05 d4 d8 10 80 00 	movl   $0x0,0x8010d8d4
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 53 2d 00 00       	call   801032c1 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 11 99 10 80 	movl   $0x80109911,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 25 99 10 80 	movl   $0x80109925,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 af 4f 00 00       	call   80105556 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 27 99 10 80 	movl   $0x80109927,(%esp)
801005c2:	e8 fa fd ff ff       	call   801003c1 <cprintf>
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005c7:	ff 45 f4             	incl   -0xc(%ebp)
801005ca:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005ce:	7e e0                	jle    801005b0 <panic+0x5c>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005d0:	c7 05 8c d8 10 80 01 	movl   $0x1,0x8010d88c
801005d7:	00 00 00 
  for(;;)
    ;
801005da:	eb fe                	jmp    801005da <panic+0x86>

801005dc <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005dc:	55                   	push   %ebp
801005dd:	89 e5                	mov    %esp,%ebp
801005df:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005e2:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005e9:	00 
801005ea:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005f1:	e8 fd fc ff ff       	call   801002f3 <outb>
  pos = inb(CRTPORT+1) << 8;
801005f6:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005fd:	e8 d6 fc ff ff       	call   801002d8 <inb>
80100602:	0f b6 c0             	movzbl %al,%eax
80100605:	c1 e0 08             	shl    $0x8,%eax
80100608:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010060b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100612:	00 
80100613:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010061a:	e8 d4 fc ff ff       	call   801002f3 <outb>
  pos |= inb(CRTPORT+1);
8010061f:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100626:	e8 ad fc ff ff       	call   801002d8 <inb>
8010062b:	0f b6 c0             	movzbl %al,%eax
8010062e:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100631:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100635:	75 1b                	jne    80100652 <cgaputc+0x76>
    pos += 80 - pos%80;
80100637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010063a:	b9 50 00 00 00       	mov    $0x50,%ecx
8010063f:	99                   	cltd   
80100640:	f7 f9                	idiv   %ecx
80100642:	89 d0                	mov    %edx,%eax
80100644:	ba 50 00 00 00       	mov    $0x50,%edx
80100649:	29 c2                	sub    %eax,%edx
8010064b:	89 d0                	mov    %edx,%eax
8010064d:	01 45 f4             	add    %eax,-0xc(%ebp)
80100650:	eb 34                	jmp    80100686 <cgaputc+0xaa>
  else if(c == BACKSPACE){
80100652:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100659:	75 0b                	jne    80100666 <cgaputc+0x8a>
    if(pos > 0) --pos;
8010065b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010065f:	7e 25                	jle    80100686 <cgaputc+0xaa>
80100661:	ff 4d f4             	decl   -0xc(%ebp)
80100664:	eb 20                	jmp    80100686 <cgaputc+0xaa>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100666:	8b 0d 04 b0 10 80    	mov    0x8010b004,%ecx
8010066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010066f:	8d 50 01             	lea    0x1(%eax),%edx
80100672:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100675:	01 c0                	add    %eax,%eax
80100677:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067a:	8b 45 08             	mov    0x8(%ebp),%eax
8010067d:	0f b6 c0             	movzbl %al,%eax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
80100686:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068a:	78 09                	js     80100695 <cgaputc+0xb9>
8010068c:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100693:	7e 0c                	jle    801006a1 <cgaputc+0xc5>
    panic("pos under/overflow");
80100695:	c7 04 24 2b 99 10 80 	movl   $0x8010992b,(%esp)
8010069c:	e8 b3 fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a1:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006a8:	7e 53                	jle    801006fd <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006aa:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801006af:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b5:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801006ba:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c1:	00 
801006c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801006c6:	89 04 24             	mov    %eax,(%esp)
801006c9:	e8 fd 50 00 00       	call   801057cb <memmove>
    pos -= 80;
801006ce:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d2:	b8 80 07 00 00       	mov    $0x780,%eax
801006d7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006da:	01 c0                	add    %eax,%eax
801006dc:	8b 0d 04 b0 10 80    	mov    0x8010b004,%ecx
801006e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006e5:	01 d2                	add    %edx,%edx
801006e7:	01 ca                	add    %ecx,%edx
801006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801006ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f4:	00 
801006f5:	89 14 24             	mov    %edx,(%esp)
801006f8:	e8 05 50 00 00       	call   80105702 <memset>
  }

  outb(CRTPORT, 14);
801006fd:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100704:	00 
80100705:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010070c:	e8 e2 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos>>8);
80100711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100714:	c1 f8 08             	sar    $0x8,%eax
80100717:	0f b6 c0             	movzbl %al,%eax
8010071a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010071e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100725:	e8 c9 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT, 15);
8010072a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100731:	00 
80100732:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100739:	e8 b5 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos);
8010073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	89 44 24 04          	mov    %eax,0x4(%esp)
80100748:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010074f:	e8 9f fb ff ff       	call   801002f3 <outb>
  crt[pos] = ' ' | 0x0700;
80100754:	8b 15 04 b0 10 80    	mov    0x8010b004,%edx
8010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010075d:	01 c0                	add    %eax,%eax
8010075f:	01 d0                	add    %edx,%eax
80100761:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100766:	c9                   	leave  
80100767:	c3                   	ret    

80100768 <consputc>:

void
consputc(int c)
{
80100768:	55                   	push   %ebp
80100769:	89 e5                	mov    %esp,%ebp
8010076b:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010076e:	a1 8c d8 10 80       	mov    0x8010d88c,%eax
80100773:	85 c0                	test   %eax,%eax
80100775:	74 07                	je     8010077e <consputc+0x16>
    cli();
80100777:	e8 93 fb ff ff       	call   8010030f <cli>
    for(;;)
      ;
8010077c:	eb fe                	jmp    8010077c <consputc+0x14>
  }

  if(c == BACKSPACE){
8010077e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100785:	75 26                	jne    801007ad <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 35 70 00 00       	call   801077c8 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 29 70 00 00       	call   801077c8 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 1d 70 00 00       	call   801077c8 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 10 70 00 00       	call   801077c8 <uartputc>
  cgaputc(c);
801007b8:	8b 45 08             	mov    0x8(%ebp),%eax
801007bb:	89 04 24             	mov    %eax,(%esp)
801007be:	e8 19 fe ff ff       	call   801005dc <cgaputc>
}
801007c3:	c9                   	leave  
801007c4:	c3                   	ret    

801007c5 <copy_buf>:

#define C(x)  ((x)-'@')  // Control-x


void copy_buf(char *dst, char *src, int len)
{
801007c5:	55                   	push   %ebp
801007c6:	89 e5                	mov    %esp,%ebp
801007c8:	83 ec 10             	sub    $0x10,%esp
  int i;

  for (i = 0; i < len; i++) {
801007cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801007d2:	eb 17                	jmp    801007eb <copy_buf+0x26>
    dst[i] = src[i];
801007d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801007d7:	8b 45 08             	mov    0x8(%ebp),%eax
801007da:	01 c2                	add    %eax,%edx
801007dc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
801007df:	8b 45 0c             	mov    0xc(%ebp),%eax
801007e2:	01 c8                	add    %ecx,%eax
801007e4:	8a 00                	mov    (%eax),%al
801007e6:	88 02                	mov    %al,(%edx)

void copy_buf(char *dst, char *src, int len)
{
  int i;

  for (i = 0; i < len; i++) {
801007e8:	ff 45 fc             	incl   -0x4(%ebp)
801007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007ee:	3b 45 10             	cmp    0x10(%ebp),%eax
801007f1:	7c e1                	jl     801007d4 <copy_buf+0xf>
    dst[i] = src[i];
  }
}
801007f3:	c9                   	leave  
801007f4:	c3                   	ret    

801007f5 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801007f5:	55                   	push   %ebp
801007f6:	89 e5                	mov    %esp,%ebp
801007f8:	57                   	push   %edi
801007f9:	56                   	push   %esi
801007fa:	53                   	push   %ebx
801007fb:	83 ec 2c             	sub    $0x2c,%esp
  int c, doprocdump = 0, doconsoleswitch = 0;
801007fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100805:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  acquire(&cons.lock);
8010080c:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100813:	e8 87 4c 00 00       	call   8010549f <acquire>
  while((c = getc()) >= 0){
80100818:	e9 eb 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    switch(c){
8010081d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100820:	83 f8 14             	cmp    $0x14,%eax
80100823:	74 3b                	je     80100860 <consoleintr+0x6b>
80100825:	83 f8 14             	cmp    $0x14,%eax
80100828:	7f 13                	jg     8010083d <consoleintr+0x48>
8010082a:	83 f8 08             	cmp    $0x8,%eax
8010082d:	0f 84 16 01 00 00    	je     80100949 <consoleintr+0x154>
80100833:	83 f8 10             	cmp    $0x10,%eax
80100836:	74 1c                	je     80100854 <consoleintr+0x5f>
80100838:	e9 3c 01 00 00       	jmp    80100979 <consoleintr+0x184>
8010083d:	83 f8 15             	cmp    $0x15,%eax
80100840:	0f 84 db 00 00 00    	je     80100921 <consoleintr+0x12c>
80100846:	83 f8 7f             	cmp    $0x7f,%eax
80100849:	0f 84 fa 00 00 00    	je     80100949 <consoleintr+0x154>
8010084f:	e9 25 01 00 00       	jmp    80100979 <consoleintr+0x184>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      // cprintf("PID of myPROC is %d\n.", myproc()->pid);
      doprocdump = 1;
80100854:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      break;
8010085b:	e9 a8 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('T'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      if (active+1 > MAX_VC){
80100860:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100865:	40                   	inc    %eax
80100866:	83 f8 04             	cmp    $0x4,%eax
80100869:	7e 23                	jle    8010088e <consoleintr+0x99>
        active = 1;
8010086b:	c7 05 00 b0 10 80 01 	movl   $0x1,0x8010b000
80100872:	00 00 00 
        input = buf1;
80100875:	ba a0 32 11 80       	mov    $0x801132a0,%edx
8010087a:	bb 20 d6 10 80       	mov    $0x8010d620,%ebx
8010087f:	b8 23 00 00 00       	mov    $0x23,%eax
80100884:	89 d7                	mov    %edx,%edi
80100886:	89 de                	mov    %ebx,%esi
80100888:	89 c1                	mov    %eax,%ecx
8010088a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
8010088c:	eb 6e                	jmp    801008fc <consoleintr+0x107>
      } else{
        active = active + 1;
8010088e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100893:	40                   	inc    %eax
80100894:	a3 00 b0 10 80       	mov    %eax,0x8010b000
        if(active == 2){
80100899:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010089e:	83 f8 02             	cmp    $0x2,%eax
801008a1:	75 17                	jne    801008ba <consoleintr+0xc5>
          buf2 = input;
801008a3:	ba c0 d6 10 80       	mov    $0x8010d6c0,%edx
801008a8:	bb a0 32 11 80       	mov    $0x801132a0,%ebx
801008ad:	b8 23 00 00 00       	mov    $0x23,%eax
801008b2:	89 d7                	mov    %edx,%edi
801008b4:	89 de                	mov    %ebx,%esi
801008b6:	89 c1                	mov    %eax,%ecx
801008b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 3){
801008ba:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801008bf:	83 f8 03             	cmp    $0x3,%eax
801008c2:	75 17                	jne    801008db <consoleintr+0xe6>
          buf3 = input;
801008c4:	ba 60 d7 10 80       	mov    $0x8010d760,%edx
801008c9:	bb a0 32 11 80       	mov    $0x801132a0,%ebx
801008ce:	b8 23 00 00 00       	mov    $0x23,%eax
801008d3:	89 d7                	mov    %edx,%edi
801008d5:	89 de                	mov    %ebx,%esi
801008d7:	89 c1                	mov    %eax,%ecx
801008d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 4){
801008db:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801008e0:	83 f8 04             	cmp    $0x4,%eax
801008e3:	75 17                	jne    801008fc <consoleintr+0x107>
          buf4 = input;
801008e5:	ba 00 d8 10 80       	mov    $0x8010d800,%edx
801008ea:	bb a0 32 11 80       	mov    $0x801132a0,%ebx
801008ef:	b8 23 00 00 00       	mov    $0x23,%eax
801008f4:	89 d7                	mov    %edx,%edi
801008f6:	89 de                	mov    %ebx,%esi
801008f8:	89 c1                	mov    %eax,%ecx
801008fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
      }
      doconsoleswitch = 1;
801008fc:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      break;
80100903:	e9 00 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100908:	a1 28 33 11 80       	mov    0x80113328,%eax
8010090d:	48                   	dec    %eax
8010090e:	a3 28 33 11 80       	mov    %eax,0x80113328
        consputc(BACKSPACE);
80100913:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010091a:	e8 49 fe ff ff       	call   80100768 <consputc>
8010091f:	eb 01                	jmp    80100922 <consoleintr+0x12d>
        }
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100921:	90                   	nop
80100922:	8b 15 28 33 11 80    	mov    0x80113328,%edx
80100928:	a1 24 33 11 80       	mov    0x80113324,%eax
8010092d:	39 c2                	cmp    %eax,%edx
8010092f:	74 13                	je     80100944 <consoleintr+0x14f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100931:	a1 28 33 11 80       	mov    0x80113328,%eax
80100936:	48                   	dec    %eax
80100937:	83 e0 7f             	and    $0x7f,%eax
8010093a:	8a 80 a0 32 11 80    	mov    -0x7feecd60(%eax),%al
        }
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100940:	3c 0a                	cmp    $0xa,%al
80100942:	75 c4                	jne    80100908 <consoleintr+0x113>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100944:	e9 bf 00 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100949:	8b 15 28 33 11 80    	mov    0x80113328,%edx
8010094f:	a1 24 33 11 80       	mov    0x80113324,%eax
80100954:	39 c2                	cmp    %eax,%edx
80100956:	74 1c                	je     80100974 <consoleintr+0x17f>
        input.e--;
80100958:	a1 28 33 11 80       	mov    0x80113328,%eax
8010095d:	48                   	dec    %eax
8010095e:	a3 28 33 11 80       	mov    %eax,0x80113328
        consputc(BACKSPACE);
80100963:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010096a:	e8 f9 fd ff ff       	call   80100768 <consputc>
      }
      break;
8010096f:	e9 94 00 00 00       	jmp    80100a08 <consoleintr+0x213>
80100974:	e9 8f 00 00 00       	jmp    80100a08 <consoleintr+0x213>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100979:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010097d:	0f 84 84 00 00 00    	je     80100a07 <consoleintr+0x212>
80100983:	8b 15 28 33 11 80    	mov    0x80113328,%edx
80100989:	a1 20 33 11 80       	mov    0x80113320,%eax
8010098e:	29 c2                	sub    %eax,%edx
80100990:	89 d0                	mov    %edx,%eax
80100992:	83 f8 7f             	cmp    $0x7f,%eax
80100995:	77 70                	ja     80100a07 <consoleintr+0x212>
        c = (c == '\r') ? '\n' : c;
80100997:	83 7d dc 0d          	cmpl   $0xd,-0x24(%ebp)
8010099b:	74 05                	je     801009a2 <consoleintr+0x1ad>
8010099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009a0:	eb 05                	jmp    801009a7 <consoleintr+0x1b2>
801009a2:	b8 0a 00 00 00       	mov    $0xa,%eax
801009a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009aa:	a1 28 33 11 80       	mov    0x80113328,%eax
801009af:	8d 50 01             	lea    0x1(%eax),%edx
801009b2:	89 15 28 33 11 80    	mov    %edx,0x80113328
801009b8:	83 e0 7f             	and    $0x7f,%eax
801009bb:	89 c2                	mov    %eax,%edx
801009bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c0:	88 82 a0 32 11 80    	mov    %al,-0x7feecd60(%edx)
        consputc(c);
801009c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c9:	89 04 24             	mov    %eax,(%esp)
801009cc:	e8 97 fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009d1:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
801009d5:	74 18                	je     801009ef <consoleintr+0x1fa>
801009d7:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
801009db:	74 12                	je     801009ef <consoleintr+0x1fa>
801009dd:	a1 28 33 11 80       	mov    0x80113328,%eax
801009e2:	8b 15 20 33 11 80    	mov    0x80113320,%edx
801009e8:	83 ea 80             	sub    $0xffffff80,%edx
801009eb:	39 d0                	cmp    %edx,%eax
801009ed:	75 18                	jne    80100a07 <consoleintr+0x212>
          input.w = input.e;
801009ef:	a1 28 33 11 80       	mov    0x80113328,%eax
801009f4:	a3 24 33 11 80       	mov    %eax,0x80113324
          wakeup(&input.r);
801009f9:	c7 04 24 20 33 11 80 	movl   $0x80113320,(%esp)
80100a00:	e8 b6 44 00 00       	call   80104ebb <wakeup>
        }
      }
      break;
80100a05:	eb 00                	jmp    80100a07 <consoleintr+0x212>
80100a07:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0, doconsoleswitch = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100a08:	8b 45 08             	mov    0x8(%ebp),%eax
80100a0b:	ff d0                	call   *%eax
80100a0d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100a10:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80100a14:	0f 89 03 fe ff ff    	jns    8010081d <consoleintr+0x28>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100a1a:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100a21:	e8 e3 4a 00 00       	call   80105509 <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 3e 99 10 80 	movl   $0x8010993e,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 24 45 00 00       	call   80104f61 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 56 99 10 80 	movl   $0x80109956,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 70 99 10 80 	movl   $0x80109970,(%esp)
80100a5f:	e8 5d f9 ff ff       	call   801003c1 <cprintf>
  }
}
80100a64:	83 c4 2c             	add    $0x2c,%esp
80100a67:	5b                   	pop    %ebx
80100a68:	5e                   	pop    %esi
80100a69:	5f                   	pop    %edi
80100a6a:	5d                   	pop    %ebp
80100a6b:	c3                   	ret    

80100a6c <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a6c:	55                   	push   %ebp
80100a6d:	89 e5                	mov    %esp,%ebp
80100a6f:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100a72:	8b 45 08             	mov    0x8(%ebp),%eax
80100a75:	89 04 24             	mov    %eax,(%esp)
80100a78:	e8 4f 11 00 00       	call   80101bcc <iunlock>
  target = n;
80100a7d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a83:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100a8a:	e8 10 4a 00 00       	call   8010549f <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 98 3a 00 00       	call   80104533 <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100aa9:	e8 5b 4a 00 00       	call   80105509 <release>
        ilock(ip);
80100aae:	8b 45 08             	mov    0x8(%ebp),%eax
80100ab1:	89 04 24             	mov    %eax,(%esp)
80100ab4:	e8 09 10 00 00       	call   80101ac2 <ilock>
        return -1;
80100ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100abe:	e9 b3 00 00 00       	jmp    80100b76 <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100ac3:	c7 44 24 04 a0 d8 10 	movl   $0x8010d8a0,0x4(%esp)
80100aca:	80 
80100acb:	c7 04 24 20 33 11 80 	movl   $0x80113320,(%esp)
80100ad2:	e8 0d 43 00 00       	call   80104de4 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100ad7:	8b 15 20 33 11 80    	mov    0x80113320,%edx
80100add:	a1 24 33 11 80       	mov    0x80113324,%eax
80100ae2:	39 c2                	cmp    %eax,%edx
80100ae4:	74 b0                	je     80100a96 <consoleread+0x2a>
80100ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ae9:	8b 40 54             	mov    0x54(%eax),%eax
80100aec:	0f bf d0             	movswl %ax,%edx
80100aef:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100af4:	39 c2                	cmp    %eax,%edx
80100af6:	75 9e                	jne    80100a96 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100af8:	a1 20 33 11 80       	mov    0x80113320,%eax
80100afd:	8d 50 01             	lea    0x1(%eax),%edx
80100b00:	89 15 20 33 11 80    	mov    %edx,0x80113320
80100b06:	83 e0 7f             	and    $0x7f,%eax
80100b09:	8a 80 a0 32 11 80    	mov    -0x7feecd60(%eax),%al
80100b0f:	0f be c0             	movsbl %al,%eax
80100b12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100b15:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100b19:	75 17                	jne    80100b32 <consoleread+0xc6>
      if(n < target){
80100b1b:	8b 45 10             	mov    0x10(%ebp),%eax
80100b1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100b21:	73 0d                	jae    80100b30 <consoleread+0xc4>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b23:	a1 20 33 11 80       	mov    0x80113320,%eax
80100b28:	48                   	dec    %eax
80100b29:	a3 20 33 11 80       	mov    %eax,0x80113320
      }
      break;
80100b2e:	eb 25                	jmp    80100b55 <consoleread+0xe9>
80100b30:	eb 23                	jmp    80100b55 <consoleread+0xe9>
    }
    *dst++ = c;
80100b32:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b35:	8d 50 01             	lea    0x1(%eax),%edx
80100b38:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b3e:	88 10                	mov    %dl,(%eax)
    --n;
80100b40:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100b43:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b47:	75 02                	jne    80100b4b <consoleread+0xdf>
      break;
80100b49:	eb 0a                	jmp    80100b55 <consoleread+0xe9>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b4f:	0f 8f 3f ff ff ff    	jg     80100a94 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100b55:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100b5c:	e8 a8 49 00 00       	call   80105509 <release>
  ilock(ip);
80100b61:	8b 45 08             	mov    0x8(%ebp),%eax
80100b64:	89 04 24             	mov    %eax,(%esp)
80100b67:	e8 56 0f 00 00       	call   80101ac2 <ilock>

  return target - n;
80100b6c:	8b 45 10             	mov    0x10(%ebp),%eax
80100b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b72:	29 c2                	sub    %eax,%edx
80100b74:	89 d0                	mov    %edx,%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b78:	55                   	push   %ebp
80100b79:	89 e5                	mov    %esp,%ebp
80100b7b:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (active == ip->minor){
80100b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80100b81:	8b 40 54             	mov    0x54(%eax),%eax
80100b84:	0f bf d0             	movswl %ax,%edx
80100b87:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100b8c:	39 c2                	cmp    %eax,%edx
80100b8e:	75 5a                	jne    80100bea <consolewrite+0x72>
    iunlock(ip);
80100b90:	8b 45 08             	mov    0x8(%ebp),%eax
80100b93:	89 04 24             	mov    %eax,(%esp)
80100b96:	e8 31 10 00 00       	call   80101bcc <iunlock>
    acquire(&cons.lock);
80100b9b:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100ba2:	e8 f8 48 00 00       	call   8010549f <acquire>
    for(i = 0; i < n; i++)
80100ba7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100bae:	eb 1b                	jmp    80100bcb <consolewrite+0x53>
      consputc(buf[i] & 0xff);
80100bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100bb6:	01 d0                	add    %edx,%eax
80100bb8:	8a 00                	mov    (%eax),%al
80100bba:	0f be c0             	movsbl %al,%eax
80100bbd:	0f b6 c0             	movzbl %al,%eax
80100bc0:	89 04 24             	mov    %eax,(%esp)
80100bc3:	e8 a0 fb ff ff       	call   80100768 <consputc>
  int i;

  if (active == ip->minor){
    iunlock(ip);
    acquire(&cons.lock);
    for(i = 0; i < n; i++)
80100bc8:	ff 45 f4             	incl   -0xc(%ebp)
80100bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bce:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bd1:	7c dd                	jl     80100bb0 <consolewrite+0x38>
      consputc(buf[i] & 0xff);
    release(&cons.lock);
80100bd3:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100bda:	e8 2a 49 00 00       	call   80105509 <release>
    ilock(ip);
80100bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80100be2:	89 04 24             	mov    %eax,(%esp)
80100be5:	e8 d8 0e 00 00       	call   80101ac2 <ilock>
  }
  return n;
80100bea:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bed:	c9                   	leave  
80100bee:	c3                   	ret    

80100bef <consoleinit>:

void
consoleinit(void)
{
80100bef:	55                   	push   %ebp
80100bf0:	89 e5                	mov    %esp,%ebp
80100bf2:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100bf5:	c7 44 24 04 89 99 10 	movl   $0x80109989,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100c04:	e8 75 48 00 00       	call   8010547e <initlock>

  devsw[CONSOLE].write = consolewrite;
80100c09:	c7 05 8c 3e 11 80 78 	movl   $0x80100b78,0x80113e8c
80100c10:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c13:	c7 05 88 3e 11 80 6c 	movl   $0x80100a6c,0x80113e88
80100c1a:	0a 10 80 
  cons.locking = 1;
80100c1d:	c7 05 d4 d8 10 80 01 	movl   $0x1,0x8010d8d4
80100c24:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c2e:	00 
80100c2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c36:	e8 94 20 00 00       	call   80102ccf <ioapicenable>
}
80100c3b:	c9                   	leave  
80100c3c:	c3                   	ret    
80100c3d:	00 00                	add    %al,(%eax)
	...

80100c40 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c40:	55                   	push   %ebp
80100c41:	89 e5                	mov    %esp,%ebp
80100c43:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c49:	e8 e5 38 00 00       	call   80104533 <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 b5 2b 00 00       	call   8010380b <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 cc 1a 00 00       	call   8010272d <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 1e 2c 00 00       	call   8010388d <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 91 99 10 80 	movl   $0x80109991,(%esp)
80100c76:	e8 46 f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c80:	e9 f6 03 00 00       	jmp    8010107b <exec+0x43b>
  }
  ilock(ip);
80100c85:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c88:	89 04 24             	mov    %eax,(%esp)
80100c8b:	e8 32 0e 00 00       	call   80101ac2 <ilock>
  pgdir = 0;
80100c90:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c97:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100c9e:	00 
80100c9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100ca6:	00 
80100ca7:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100cad:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cb4:	89 04 24             	mov    %eax,(%esp)
80100cb7:	e8 9d 12 00 00       	call   80101f59 <readi>
80100cbc:	83 f8 34             	cmp    $0x34,%eax
80100cbf:	74 05                	je     80100cc6 <exec+0x86>
    goto bad;
80100cc1:	e9 89 03 00 00       	jmp    8010104f <exec+0x40f>
  if(elf.magic != ELF_MAGIC)
80100cc6:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100ccc:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cd1:	74 05                	je     80100cd8 <exec+0x98>
    goto bad;
80100cd3:	e9 77 03 00 00       	jmp    8010104f <exec+0x40f>

  if((pgdir = setupkvm()) == 0)
80100cd8:	e8 cd 7a 00 00       	call   801087aa <setupkvm>
80100cdd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ce0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ce4:	75 05                	jne    80100ceb <exec+0xab>
    goto bad;
80100ce6:	e9 64 03 00 00       	jmp    8010104f <exec+0x40f>

  // Load program into memory.
  sz = 0;
80100ceb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cf2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cf9:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100cff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d02:	e9 fb 00 00 00       	jmp    80100e02 <exec+0x1c2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d0a:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100d11:	00 
80100d12:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d16:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d23:	89 04 24             	mov    %eax,(%esp)
80100d26:	e8 2e 12 00 00       	call   80101f59 <readi>
80100d2b:	83 f8 20             	cmp    $0x20,%eax
80100d2e:	74 05                	je     80100d35 <exec+0xf5>
      goto bad;
80100d30:	e9 1a 03 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.type != ELF_PROG_LOAD)
80100d35:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d3b:	83 f8 01             	cmp    $0x1,%eax
80100d3e:	74 05                	je     80100d45 <exec+0x105>
      continue;
80100d40:	e9 b1 00 00 00       	jmp    80100df6 <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100d45:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d4b:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d51:	39 c2                	cmp    %eax,%edx
80100d53:	73 05                	jae    80100d5a <exec+0x11a>
      goto bad;
80100d55:	e9 f5 02 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d5a:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d60:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d66:	01 c2                	add    %eax,%edx
80100d68:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d6e:	39 c2                	cmp    %eax,%edx
80100d70:	73 05                	jae    80100d77 <exec+0x137>
      goto bad;
80100d72:	e9 d8 02 00 00       	jmp    8010104f <exec+0x40f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d77:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d7d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d83:	01 d0                	add    %edx,%eax
80100d85:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d93:	89 04 24             	mov    %eax,(%esp)
80100d96:	e8 db 7d 00 00       	call   80108b76 <allocuvm>
80100d9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d9e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100da2:	75 05                	jne    80100da9 <exec+0x169>
      goto bad;
80100da4:	e9 a6 02 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.vaddr % PGSIZE != 0)
80100da9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100daf:	25 ff 0f 00 00       	and    $0xfff,%eax
80100db4:	85 c0                	test   %eax,%eax
80100db6:	74 05                	je     80100dbd <exec+0x17d>
      goto bad;
80100db8:	e9 92 02 00 00       	jmp    8010104f <exec+0x40f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100dbd:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100dc3:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100dc9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100dcf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100dd3:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100dd7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100dda:	89 54 24 08          	mov    %edx,0x8(%esp)
80100dde:	89 44 24 04          	mov    %eax,0x4(%esp)
80100de2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100de5:	89 04 24             	mov    %eax,(%esp)
80100de8:	e8 a6 7c 00 00       	call   80108a93 <loaduvm>
80100ded:	85 c0                	test   %eax,%eax
80100def:	79 05                	jns    80100df6 <exec+0x1b6>
      goto bad;
80100df1:	e9 59 02 00 00       	jmp    8010104f <exec+0x40f>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100df6:	ff 45 ec             	incl   -0x14(%ebp)
80100df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dfc:	83 c0 20             	add    $0x20,%eax
80100dff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e02:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
80100e08:	0f b7 c0             	movzwl %ax,%eax
80100e0b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e0e:	0f 8f f3 fe ff ff    	jg     80100d07 <exec+0xc7>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e14:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e17:	89 04 24             	mov    %eax,(%esp)
80100e1a:	e8 a2 0e 00 00       	call   80101cc1 <iunlockput>
  end_op();
80100e1f:	e8 69 2a 00 00       	call   8010388d <end_op>
  ip = 0;
80100e24:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e2e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e38:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e3e:	05 00 20 00 00       	add    $0x2000,%eax
80100e43:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e51:	89 04 24             	mov    %eax,(%esp)
80100e54:	e8 1d 7d 00 00       	call   80108b76 <allocuvm>
80100e59:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e5c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e60:	75 05                	jne    80100e67 <exec+0x227>
    goto bad;
80100e62:	e9 e8 01 00 00       	jmp    8010104f <exec+0x40f>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e6a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e76:	89 04 24             	mov    %eax,(%esp)
80100e79:	e8 68 7f 00 00       	call   80108de6 <clearpteu>
  sp = sz;
80100e7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e81:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e84:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e8b:	e9 95 00 00 00       	jmp    80100f25 <exec+0x2e5>
    if(argc >= MAXARG)
80100e90:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e94:	76 05                	jbe    80100e9b <exec+0x25b>
      goto bad;
80100e96:	e9 b4 01 00 00       	jmp    8010104f <exec+0x40f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea8:	01 d0                	add    %edx,%eax
80100eaa:	8b 00                	mov    (%eax),%eax
80100eac:	89 04 24             	mov    %eax,(%esp)
80100eaf:	e8 a1 4a 00 00       	call   80105955 <strlen>
80100eb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb7:	29 c2                	sub    %eax,%edx
80100eb9:	89 d0                	mov    %edx,%eax
80100ebb:	48                   	dec    %eax
80100ebc:	83 e0 fc             	and    $0xfffffffc,%eax
80100ebf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ecf:	01 d0                	add    %edx,%eax
80100ed1:	8b 00                	mov    (%eax),%eax
80100ed3:	89 04 24             	mov    %eax,(%esp)
80100ed6:	e8 7a 4a 00 00       	call   80105955 <strlen>
80100edb:	40                   	inc    %eax
80100edc:	89 c2                	mov    %eax,%edx
80100ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eeb:	01 c8                	add    %ecx,%eax
80100eed:	8b 00                	mov    (%eax),%eax
80100eef:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100ef3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ef7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100efa:	89 44 24 04          	mov    %eax,0x4(%esp)
80100efe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f01:	89 04 24             	mov    %eax,(%esp)
80100f04:	e8 95 80 00 00       	call   80108f9e <copyout>
80100f09:	85 c0                	test   %eax,%eax
80100f0b:	79 05                	jns    80100f12 <exec+0x2d2>
      goto bad;
80100f0d:	e9 3d 01 00 00       	jmp    8010104f <exec+0x40f>
    ustack[3+argc] = sp;
80100f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f15:	8d 50 03             	lea    0x3(%eax),%edx
80100f18:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f1b:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f22:	ff 45 e4             	incl   -0x1c(%ebp)
80100f25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f32:	01 d0                	add    %edx,%eax
80100f34:	8b 00                	mov    (%eax),%eax
80100f36:	85 c0                	test   %eax,%eax
80100f38:	0f 85 52 ff ff ff    	jne    80100e90 <exec+0x250>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f41:	83 c0 03             	add    $0x3,%eax
80100f44:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f4b:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f4f:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f56:	ff ff ff 
  ustack[1] = argc;
80100f59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5c:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f65:	40                   	inc    %eax
80100f66:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f70:	29 d0                	sub    %edx,%eax
80100f72:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7b:	83 c0 04             	add    $0x4,%eax
80100f7e:	c1 e0 02             	shl    $0x2,%eax
80100f81:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f87:	83 c0 04             	add    $0x4,%eax
80100f8a:	c1 e0 02             	shl    $0x2,%eax
80100f8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100f91:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f97:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fa5:	89 04 24             	mov    %eax,(%esp)
80100fa8:	e8 f1 7f 00 00       	call   80108f9e <copyout>
80100fad:	85 c0                	test   %eax,%eax
80100faf:	79 05                	jns    80100fb6 <exec+0x376>
    goto bad;
80100fb1:	e9 99 00 00 00       	jmp    8010104f <exec+0x40f>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fc2:	eb 13                	jmp    80100fd7 <exec+0x397>
    if(*s == '/')
80100fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc7:	8a 00                	mov    (%eax),%al
80100fc9:	3c 2f                	cmp    $0x2f,%al
80100fcb:	75 07                	jne    80100fd4 <exec+0x394>
      last = s+1;
80100fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd0:	40                   	inc    %eax
80100fd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fd4:	ff 45 f4             	incl   -0xc(%ebp)
80100fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fda:	8a 00                	mov    (%eax),%al
80100fdc:	84 c0                	test   %al,%al
80100fde:	75 e4                	jne    80100fc4 <exec+0x384>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fe0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fe3:	8d 50 6c             	lea    0x6c(%eax),%edx
80100fe6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100fed:	00 
80100fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ff5:	89 14 24             	mov    %edx,(%esp)
80100ff8:	e8 11 49 00 00       	call   8010590e <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ffd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101000:	8b 40 04             	mov    0x4(%eax),%eax
80101003:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80101006:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101009:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010100c:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
8010100f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101012:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101015:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80101017:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010101a:	8b 40 18             	mov    0x18(%eax),%eax
8010101d:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80101023:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101026:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101029:	8b 40 18             	mov    0x18(%eax),%eax
8010102c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010102f:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101032:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101035:	89 04 24             	mov    %eax,(%esp)
80101038:	e8 47 78 00 00       	call   80108884 <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 08 7d 00 00       	call   80108d50 <freevm>
  return 0;
80101048:	b8 00 00 00 00       	mov    $0x0,%eax
8010104d:	eb 2c                	jmp    8010107b <exec+0x43b>

 bad:
  if(pgdir)
8010104f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101053:	74 0b                	je     80101060 <exec+0x420>
    freevm(pgdir);
80101055:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101058:	89 04 24             	mov    %eax,(%esp)
8010105b:	e8 f0 7c 00 00       	call   80108d50 <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 50 0c 00 00       	call   80101cc1 <iunlockput>
    end_op();
80101071:	e8 17 28 00 00       	call   8010388d <end_op>
  }
  return -1;
80101076:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010107b:	c9                   	leave  
8010107c:	c3                   	ret    
8010107d:	00 00                	add    %al,(%eax)
	...

80101080 <strcpy1>:
#include "file.h"
#include "container.h"



char* strcpy1(char *s, char *t){
80101080:	55                   	push   %ebp
80101081:	89 e5                	mov    %esp,%ebp
80101083:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80101086:	8b 45 08             	mov    0x8(%ebp),%eax
80101089:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
8010108c:	90                   	nop
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	8d 50 01             	lea    0x1(%eax),%edx
80101093:	89 55 08             	mov    %edx,0x8(%ebp)
80101096:	8b 55 0c             	mov    0xc(%ebp),%edx
80101099:	8d 4a 01             	lea    0x1(%edx),%ecx
8010109c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010109f:	8a 12                	mov    (%edx),%dl
801010a1:	88 10                	mov    %dl,(%eax)
801010a3:	8a 00                	mov    (%eax),%al
801010a5:	84 c0                	test   %al,%al
801010a7:	75 e4                	jne    8010108d <strcpy1+0xd>
    ;
  return os;
801010a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801010ac:	c9                   	leave  
801010ad:	c3                   	ret    

801010ae <strcmp2>:

int
strcmp2(const char *p, const char *q){
801010ae:	55                   	push   %ebp
801010af:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
801010b1:	eb 06                	jmp    801010b9 <strcmp2+0xb>
    p++, q++;
801010b3:	ff 45 08             	incl   0x8(%ebp)
801010b6:	ff 45 0c             	incl   0xc(%ebp)
  return os;
}

int
strcmp2(const char *p, const char *q){
  while(*p && *p == *q)
801010b9:	8b 45 08             	mov    0x8(%ebp),%eax
801010bc:	8a 00                	mov    (%eax),%al
801010be:	84 c0                	test   %al,%al
801010c0:	74 0e                	je     801010d0 <strcmp2+0x22>
801010c2:	8b 45 08             	mov    0x8(%ebp),%eax
801010c5:	8a 10                	mov    (%eax),%dl
801010c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801010ca:	8a 00                	mov    (%eax),%al
801010cc:	38 c2                	cmp    %al,%dl
801010ce:	74 e3                	je     801010b3 <strcmp2+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801010d0:	8b 45 08             	mov    0x8(%ebp),%eax
801010d3:	8a 00                	mov    (%eax),%al
801010d5:	0f b6 d0             	movzbl %al,%edx
801010d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801010db:	8a 00                	mov    (%eax),%al
801010dd:	0f b6 c0             	movzbl %al,%eax
801010e0:	29 c2                	sub    %eax,%edx
801010e2:	89 d0                	mov    %edx,%eax
}
801010e4:	5d                   	pop    %ebp
801010e5:	c3                   	ret    

801010e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010e6:	55                   	push   %ebp
801010e7:	89 e5                	mov    %esp,%ebp
801010e9:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801010ec:	c7 44 24 04 9d 99 10 	movl   $0x8010999d,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801010fb:	e8 7e 43 00 00       	call   8010547e <initlock>
}
80101100:	c9                   	leave  
80101101:	c3                   	ret    

80101102 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101102:	55                   	push   %ebp
80101103:	89 e5                	mov    %esp,%ebp
80101105:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101108:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010110f:	e8 8b 43 00 00       	call   8010549f <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101114:	c7 45 f4 74 33 11 80 	movl   $0x80113374,-0xc(%ebp)
8010111b:	eb 29                	jmp    80101146 <filealloc+0x44>
    if(f->ref == 0){
8010111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101120:	8b 40 04             	mov    0x4(%eax),%eax
80101123:	85 c0                	test   %eax,%eax
80101125:	75 1b                	jne    80101142 <filealloc+0x40>
      f->ref = 1;
80101127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010112a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101131:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80101138:	e8 cc 43 00 00       	call   80105509 <release>
      return f;
8010113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101140:	eb 1e                	jmp    80101160 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101142:	83 45 f4 1c          	addl   $0x1c,-0xc(%ebp)
80101146:	81 7d f4 64 3e 11 80 	cmpl   $0x80113e64,-0xc(%ebp)
8010114d:	72 ce                	jb     8010111d <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010114f:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80101156:	e8 ae 43 00 00       	call   80105509 <release>
  return 0;
8010115b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101160:	c9                   	leave  
80101161:	c3                   	ret    

80101162 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101162:	55                   	push   %ebp
80101163:	89 e5                	mov    %esp,%ebp
80101165:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101168:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010116f:	e8 2b 43 00 00       	call   8010549f <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 a4 99 10 80 	movl   $0x801099a4,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011a0:	e8 64 43 00 00       	call   80105509 <release>
  return f;
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011a8:	c9                   	leave  
801011a9:	c3                   	ret    

801011aa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011aa:	55                   	push   %ebp
801011ab:	89 e5                	mov    %esp,%ebp
801011ad:	57                   	push   %edi
801011ae:	56                   	push   %esi
801011af:	53                   	push   %ebx
801011b0:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
801011b3:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011ba:	e8 e0 42 00 00       	call   8010549f <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 ac 99 10 80 	movl   $0x801099ac,(%esp)
801011d0:	e8 7f f3 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
801011d5:	8b 45 08             	mov    0x8(%ebp),%eax
801011d8:	8b 40 04             	mov    0x4(%eax),%eax
801011db:	8d 50 ff             	lea    -0x1(%eax),%edx
801011de:	8b 45 08             	mov    0x8(%ebp),%eax
801011e1:	89 50 04             	mov    %edx,0x4(%eax)
801011e4:	8b 45 08             	mov    0x8(%ebp),%eax
801011e7:	8b 40 04             	mov    0x4(%eax),%eax
801011ea:	85 c0                	test   %eax,%eax
801011ec:	7e 0e                	jle    801011fc <fileclose+0x52>
    release(&ftable.lock);
801011ee:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011f5:	e8 0f 43 00 00       	call   80105509 <release>
801011fa:	eb 70                	jmp    8010126c <fileclose+0xc2>
    return;
  }
  ff = *f;
801011fc:	8b 45 08             	mov    0x8(%ebp),%eax
801011ff:	8d 55 cc             	lea    -0x34(%ebp),%edx
80101202:	89 c3                	mov    %eax,%ebx
80101204:	b8 07 00 00 00       	mov    $0x7,%eax
80101209:	89 d7                	mov    %edx,%edi
8010120b:	89 de                	mov    %ebx,%esi
8010120d:	89 c1                	mov    %eax,%ecx
8010120f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010121b:	8b 45 08             	mov    0x8(%ebp),%eax
8010121e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101224:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010122b:	e8 d9 42 00 00       	call   80105509 <release>

  if(ff.type == FD_PIPE)
80101230:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101233:	83 f8 01             	cmp    $0x1,%eax
80101236:	75 17                	jne    8010124f <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101238:	8a 45 d5             	mov    -0x2b(%ebp),%al
8010123b:	0f be d0             	movsbl %al,%edx
8010123e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101241:	89 54 24 04          	mov    %edx,0x4(%esp)
80101245:	89 04 24             	mov    %eax,(%esp)
80101248:	e8 7e 2f 00 00       	call   801041cb <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 af 25 00 00       	call   8010380b <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 a9 09 00 00       	call   80101c10 <iput>
    end_op();
80101267:	e8 21 26 00 00       	call   8010388d <end_op>
  }
}
8010126c:	83 c4 3c             	add    $0x3c,%esp
8010126f:	5b                   	pop    %ebx
80101270:	5e                   	pop    %esi
80101271:	5f                   	pop    %edi
80101272:	5d                   	pop    %ebp
80101273:	c3                   	ret    

80101274 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101274:	55                   	push   %ebp
80101275:	89 e5                	mov    %esp,%ebp
80101277:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010127a:	8b 45 08             	mov    0x8(%ebp),%eax
8010127d:	8b 00                	mov    (%eax),%eax
8010127f:	83 f8 02             	cmp    $0x2,%eax
80101282:	75 38                	jne    801012bc <filestat+0x48>
    ilock(f->ip);
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	8b 40 10             	mov    0x10(%eax),%eax
8010128a:	89 04 24             	mov    %eax,(%esp)
8010128d:	e8 30 08 00 00       	call   80101ac2 <ilock>
    stati(f->ip, st);
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 40 10             	mov    0x10(%eax),%eax
80101298:	8b 55 0c             	mov    0xc(%ebp),%edx
8010129b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010129f:	89 04 24             	mov    %eax,(%esp)
801012a2:	e8 6e 0c 00 00       	call   80101f15 <stati>
    iunlock(f->ip);
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	8b 40 10             	mov    0x10(%eax),%eax
801012ad:	89 04 24             	mov    %eax,(%esp)
801012b0:	e8 17 09 00 00       	call   80101bcc <iunlock>
    return 0;
801012b5:	b8 00 00 00 00       	mov    $0x0,%eax
801012ba:	eb 05                	jmp    801012c1 <filestat+0x4d>
  }
  return -1;
801012bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012c1:	c9                   	leave  
801012c2:	c3                   	ret    

801012c3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012c3:	55                   	push   %ebp
801012c4:	89 e5                	mov    %esp,%ebp
801012c6:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801012c9:	8b 45 08             	mov    0x8(%ebp),%eax
801012cc:	8a 40 08             	mov    0x8(%eax),%al
801012cf:	84 c0                	test   %al,%al
801012d1:	75 0a                	jne    801012dd <fileread+0x1a>
    return -1;
801012d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012d8:	e9 9f 00 00 00       	jmp    8010137c <fileread+0xb9>
  if(f->type == FD_PIPE)
801012dd:	8b 45 08             	mov    0x8(%ebp),%eax
801012e0:	8b 00                	mov    (%eax),%eax
801012e2:	83 f8 01             	cmp    $0x1,%eax
801012e5:	75 1e                	jne    80101305 <fileread+0x42>
    return piperead(f->pipe, addr, n);
801012e7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ea:	8b 40 0c             	mov    0xc(%eax),%eax
801012ed:	8b 55 10             	mov    0x10(%ebp),%edx
801012f0:	89 54 24 08          	mov    %edx,0x8(%esp)
801012f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801012f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801012fb:	89 04 24             	mov    %eax,(%esp)
801012fe:	e8 46 30 00 00       	call   80104349 <piperead>
80101303:	eb 77                	jmp    8010137c <fileread+0xb9>
  if(f->type == FD_INODE){
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	8b 00                	mov    (%eax),%eax
8010130a:	83 f8 02             	cmp    $0x2,%eax
8010130d:	75 61                	jne    80101370 <fileread+0xad>
    ilock(f->ip);
8010130f:	8b 45 08             	mov    0x8(%ebp),%eax
80101312:	8b 40 10             	mov    0x10(%eax),%eax
80101315:	89 04 24             	mov    %eax,(%esp)
80101318:	e8 a5 07 00 00       	call   80101ac2 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010131d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101320:	8b 45 08             	mov    0x8(%ebp),%eax
80101323:	8b 50 14             	mov    0x14(%eax),%edx
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 40 10             	mov    0x10(%eax),%eax
8010132c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101330:	89 54 24 08          	mov    %edx,0x8(%esp)
80101334:	8b 55 0c             	mov    0xc(%ebp),%edx
80101337:	89 54 24 04          	mov    %edx,0x4(%esp)
8010133b:	89 04 24             	mov    %eax,(%esp)
8010133e:	e8 16 0c 00 00       	call   80101f59 <readi>
80101343:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101346:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010134a:	7e 11                	jle    8010135d <fileread+0x9a>
      f->off += r;
8010134c:	8b 45 08             	mov    0x8(%ebp),%eax
8010134f:	8b 50 14             	mov    0x14(%eax),%edx
80101352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101355:	01 c2                	add    %eax,%edx
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010135d:	8b 45 08             	mov    0x8(%ebp),%eax
80101360:	8b 40 10             	mov    0x10(%eax),%eax
80101363:	89 04 24             	mov    %eax,(%esp)
80101366:	e8 61 08 00 00       	call   80101bcc <iunlock>
    return r;
8010136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136e:	eb 0c                	jmp    8010137c <fileread+0xb9>
  }
  panic("fileread");
80101370:	c7 04 24 b6 99 10 80 	movl   $0x801099b6,(%esp)
80101377:	e8 d8 f1 ff ff       	call   80100554 <panic>
}
8010137c:	c9                   	leave  
8010137d:	c3                   	ret    

8010137e <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010137e:	55                   	push   %ebp
8010137f:	89 e5                	mov    %esp,%ebp
80101381:	53                   	push   %ebx
80101382:	83 ec 24             	sub    $0x24,%esp
  //     x[i] = '\0';
  //     break;
  //   }
  // }

  if(f->writable == 0)
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8a 40 09             	mov    0x9(%eax),%al
8010138b:	84 c0                	test   %al,%al
8010138d:	75 0a                	jne    80101399 <filewrite+0x1b>
    return -1;
8010138f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101394:	e9 20 01 00 00       	jmp    801014b9 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101399:	8b 45 08             	mov    0x8(%ebp),%eax
8010139c:	8b 00                	mov    (%eax),%eax
8010139e:	83 f8 01             	cmp    $0x1,%eax
801013a1:	75 21                	jne    801013c4 <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
801013a3:	8b 45 08             	mov    0x8(%ebp),%eax
801013a6:	8b 40 0c             	mov    0xc(%eax),%eax
801013a9:	8b 55 10             	mov    0x10(%ebp),%edx
801013ac:	89 54 24 08          	mov    %edx,0x8(%esp)
801013b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801013b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801013b7:	89 04 24             	mov    %eax,(%esp)
801013ba:	e8 9e 2e 00 00       	call   8010425d <pipewrite>
801013bf:	e9 f5 00 00 00       	jmp    801014b9 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013c4:	8b 45 08             	mov    0x8(%ebp),%eax
801013c7:	8b 00                	mov    (%eax),%eax
801013c9:	83 f8 02             	cmp    $0x2,%eax
801013cc:	0f 85 db 00 00 00    	jne    801014ad <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801013d2:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801013d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013e0:	e9 a8 00 00 00       	jmp    8010148d <filewrite+0x10f>
      int n1 = n - i;
801013e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e8:	8b 55 10             	mov    0x10(%ebp),%edx
801013eb:	29 c2                	sub    %eax,%edx
801013ed:	89 d0                	mov    %edx,%eax
801013ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013f8:	7e 06                	jle    80101400 <filewrite+0x82>
        n1 = max;
801013fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013fd:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101400:	e8 06 24 00 00       	call   8010380b <begin_op>
      ilock(f->ip);
80101405:	8b 45 08             	mov    0x8(%ebp),%eax
80101408:	8b 40 10             	mov    0x10(%eax),%eax
8010140b:	89 04 24             	mov    %eax,(%esp)
8010140e:	e8 af 06 00 00       	call   80101ac2 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0){
80101413:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101416:	8b 45 08             	mov    0x8(%ebp),%eax
80101419:	8b 50 14             	mov    0x14(%eax),%edx
8010141c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010141f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101422:	01 c3                	add    %eax,%ebx
80101424:	8b 45 08             	mov    0x8(%ebp),%eax
80101427:	8b 40 10             	mov    0x10(%eax),%eax
8010142a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010142e:	89 54 24 08          	mov    %edx,0x8(%esp)
80101432:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101436:	89 04 24             	mov    %eax,(%esp)
80101439:	e8 7f 0c 00 00       	call   801020bd <writei>
8010143e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101441:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101445:	7e 11                	jle    80101458 <filewrite+0xda>
        f->off += r;
80101447:	8b 45 08             	mov    0x8(%ebp),%eax
8010144a:	8b 50 14             	mov    0x14(%eax),%edx
8010144d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101450:	01 c2                	add    %eax,%edx
80101452:	8b 45 08             	mov    0x8(%ebp),%eax
80101455:	89 50 14             	mov    %edx,0x14(%eax)
        // int c_num = find(x);
        // if(c_num >= 0){
        //   set_curr_disk(r, c_num);
        // }
      }
      iunlock(f->ip);
80101458:	8b 45 08             	mov    0x8(%ebp),%eax
8010145b:	8b 40 10             	mov    0x10(%eax),%eax
8010145e:	89 04 24             	mov    %eax,(%esp)
80101461:	e8 66 07 00 00       	call   80101bcc <iunlock>
      end_op();
80101466:	e8 22 24 00 00       	call   8010388d <end_op>

      if(r < 0)
8010146b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010146f:	79 02                	jns    80101473 <filewrite+0xf5>
        break;
80101471:	eb 26                	jmp    80101499 <filewrite+0x11b>
      if(r != n1)
80101473:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101476:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101479:	74 0c                	je     80101487 <filewrite+0x109>
        panic("short filewrite");
8010147b:	c7 04 24 bf 99 10 80 	movl   $0x801099bf,(%esp)
80101482:	e8 cd f0 ff ff       	call   80100554 <panic>
      i += r;
80101487:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010148a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101490:	3b 45 10             	cmp    0x10(%ebp),%eax
80101493:	0f 8c 4c ff ff ff    	jl     801013e5 <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010149c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010149f:	75 05                	jne    801014a6 <filewrite+0x128>
801014a1:	8b 45 10             	mov    0x10(%ebp),%eax
801014a4:	eb 05                	jmp    801014ab <filewrite+0x12d>
801014a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014ab:	eb 0c                	jmp    801014b9 <filewrite+0x13b>
  }
  panic("filewrite");
801014ad:	c7 04 24 cf 99 10 80 	movl   $0x801099cf,(%esp)
801014b4:	e8 9b f0 ff ff       	call   80100554 <panic>
}
801014b9:	83 c4 24             	add    $0x24,%esp
801014bc:	5b                   	pop    %ebx
801014bd:	5d                   	pop    %ebp
801014be:	c3                   	ret    
	...

801014c0 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014c0:	55                   	push   %ebp
801014c1:	89 e5                	mov    %esp,%ebp
801014c3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014c6:	8b 45 08             	mov    0x8(%ebp),%eax
801014c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801014d0:	00 
801014d1:	89 04 24             	mov    %eax,(%esp)
801014d4:	e8 dc ec ff ff       	call   801001b5 <bread>
801014d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014df:	83 c0 5c             	add    $0x5c,%eax
801014e2:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
801014e9:	00 
801014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f1:	89 04 24             	mov    %eax,(%esp)
801014f4:	e8 d2 42 00 00       	call   801057cb <memmove>
  brelse(bp);
801014f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fc:	89 04 24             	mov    %eax,(%esp)
801014ff:	e8 28 ed ff ff       	call   8010022c <brelse>
}
80101504:	c9                   	leave  
80101505:	c3                   	ret    

80101506 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101506:	55                   	push   %ebp
80101507:	89 e5                	mov    %esp,%ebp
80101509:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010150c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010150f:	8b 45 08             	mov    0x8(%ebp),%eax
80101512:	89 54 24 04          	mov    %edx,0x4(%esp)
80101516:	89 04 24             	mov    %eax,(%esp)
80101519:	e8 97 ec ff ff       	call   801001b5 <bread>
8010151e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101524:	83 c0 5c             	add    $0x5c,%eax
80101527:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010152e:	00 
8010152f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101536:	00 
80101537:	89 04 24             	mov    %eax,(%esp)
8010153a:	e8 c3 41 00 00       	call   80105702 <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 c5 24 00 00       	call   80103a0f <log_write>
  brelse(bp);
8010154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154d:	89 04 24             	mov    %eax,(%esp)
80101550:	e8 d7 ec ff ff       	call   8010022c <brelse>
}
80101555:	c9                   	leave  
80101556:	c3                   	ret    

80101557 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101557:	55                   	push   %ebp
80101558:	89 e5                	mov    %esp,%ebp
8010155a:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010155d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101564:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010156b:	e9 03 01 00 00       	jmp    80101673 <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
80101570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101573:	85 c0                	test   %eax,%eax
80101575:	79 05                	jns    8010157c <balloc+0x25>
80101577:	05 ff 0f 00 00       	add    $0xfff,%eax
8010157c:	c1 f8 0c             	sar    $0xc,%eax
8010157f:	89 c2                	mov    %eax,%edx
80101581:	a1 f8 3e 11 80       	mov    0x80113ef8,%eax
80101586:	01 d0                	add    %edx,%eax
80101588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010158c:	8b 45 08             	mov    0x8(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 1e ec ff ff       	call   801001b5 <bread>
80101597:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010159a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015a1:	e9 9b 00 00 00       	jmp    80101641 <balloc+0xea>
      m = 1 << (bi % 8);
801015a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a9:	25 07 00 00 80       	and    $0x80000007,%eax
801015ae:	85 c0                	test   %eax,%eax
801015b0:	79 05                	jns    801015b7 <balloc+0x60>
801015b2:	48                   	dec    %eax
801015b3:	83 c8 f8             	or     $0xfffffff8,%eax
801015b6:	40                   	inc    %eax
801015b7:	ba 01 00 00 00       	mov    $0x1,%edx
801015bc:	88 c1                	mov    %al,%cl
801015be:	d3 e2                	shl    %cl,%edx
801015c0:	89 d0                	mov    %edx,%eax
801015c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c8:	85 c0                	test   %eax,%eax
801015ca:	79 03                	jns    801015cf <balloc+0x78>
801015cc:	83 c0 07             	add    $0x7,%eax
801015cf:	c1 f8 03             	sar    $0x3,%eax
801015d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015d5:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
801015d9:	0f b6 c0             	movzbl %al,%eax
801015dc:	23 45 e8             	and    -0x18(%ebp),%eax
801015df:	85 c0                	test   %eax,%eax
801015e1:	75 5b                	jne    8010163e <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e6:	85 c0                	test   %eax,%eax
801015e8:	79 03                	jns    801015ed <balloc+0x96>
801015ea:	83 c0 07             	add    $0x7,%eax
801015ed:	c1 f8 03             	sar    $0x3,%eax
801015f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f3:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
801015f7:	88 d1                	mov    %dl,%cl
801015f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015fc:	09 ca                	or     %ecx,%edx
801015fe:	88 d1                	mov    %dl,%cl
80101600:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101603:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101607:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010160a:	89 04 24             	mov    %eax,(%esp)
8010160d:	e8 fd 23 00 00       	call   80103a0f <log_write>
        brelse(bp);
80101612:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101615:	89 04 24             	mov    %eax,(%esp)
80101618:	e8 0f ec ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
8010161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101620:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101623:	01 c2                	add    %eax,%edx
80101625:	8b 45 08             	mov    0x8(%ebp),%eax
80101628:	89 54 24 04          	mov    %edx,0x4(%esp)
8010162c:	89 04 24             	mov    %eax,(%esp)
8010162f:	e8 d2 fe ff ff       	call   80101506 <bzero>
        return b + bi;
80101634:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163a:	01 d0                	add    %edx,%eax
8010163c:	eb 51                	jmp    8010168f <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010163e:	ff 45 f0             	incl   -0x10(%ebp)
80101641:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101648:	7f 17                	jg     80101661 <balloc+0x10a>
8010164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101650:	01 d0                	add    %edx,%eax
80101652:	89 c2                	mov    %eax,%edx
80101654:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
80101659:	39 c2                	cmp    %eax,%edx
8010165b:	0f 82 45 ff ff ff    	jb     801015a6 <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101661:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101664:	89 04 24             	mov    %eax,(%esp)
80101667:	e8 c0 eb ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010166c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101673:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101676:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
8010167b:	39 c2                	cmp    %eax,%edx
8010167d:	0f 82 ed fe ff ff    	jb     80101570 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101683:	c7 04 24 dc 99 10 80 	movl   $0x801099dc,(%esp)
8010168a:	e8 c5 ee ff ff       	call   80100554 <panic>
}
8010168f:	c9                   	leave  
80101690:	c3                   	ret    

80101691 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101691:	55                   	push   %ebp
80101692:	89 e5                	mov    %esp,%ebp
80101694:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101697:	c7 44 24 04 e0 3e 11 	movl   $0x80113ee0,0x4(%esp)
8010169e:	80 
8010169f:	8b 45 08             	mov    0x8(%ebp),%eax
801016a2:	89 04 24             	mov    %eax,(%esp)
801016a5:	e8 16 fe ff ff       	call   801014c0 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801016aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ad:	c1 e8 0c             	shr    $0xc,%eax
801016b0:	89 c2                	mov    %eax,%edx
801016b2:	a1 f8 3e 11 80       	mov    0x80113ef8,%eax
801016b7:	01 c2                	add    %eax,%edx
801016b9:	8b 45 08             	mov    0x8(%ebp),%eax
801016bc:	89 54 24 04          	mov    %edx,0x4(%esp)
801016c0:	89 04 24             	mov    %eax,(%esp)
801016c3:	e8 ed ea ff ff       	call   801001b5 <bread>
801016c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ce:	25 ff 0f 00 00       	and    $0xfff,%eax
801016d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d9:	25 07 00 00 80       	and    $0x80000007,%eax
801016de:	85 c0                	test   %eax,%eax
801016e0:	79 05                	jns    801016e7 <bfree+0x56>
801016e2:	48                   	dec    %eax
801016e3:	83 c8 f8             	or     $0xfffffff8,%eax
801016e6:	40                   	inc    %eax
801016e7:	ba 01 00 00 00       	mov    $0x1,%edx
801016ec:	88 c1                	mov    %al,%cl
801016ee:	d3 e2                	shl    %cl,%edx
801016f0:	89 d0                	mov    %edx,%eax
801016f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f8:	85 c0                	test   %eax,%eax
801016fa:	79 03                	jns    801016ff <bfree+0x6e>
801016fc:	83 c0 07             	add    $0x7,%eax
801016ff:	c1 f8 03             	sar    $0x3,%eax
80101702:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101705:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101709:	0f b6 c0             	movzbl %al,%eax
8010170c:	23 45 ec             	and    -0x14(%ebp),%eax
8010170f:	85 c0                	test   %eax,%eax
80101711:	75 0c                	jne    8010171f <bfree+0x8e>
    panic("freeing free block");
80101713:	c7 04 24 f2 99 10 80 	movl   $0x801099f2,(%esp)
8010171a:	e8 35 ee ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
8010171f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101722:	85 c0                	test   %eax,%eax
80101724:	79 03                	jns    80101729 <bfree+0x98>
80101726:	83 c0 07             	add    $0x7,%eax
80101729:	c1 f8 03             	sar    $0x3,%eax
8010172c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010172f:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
80101733:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101736:	f7 d1                	not    %ecx
80101738:	21 ca                	and    %ecx,%edx
8010173a:	88 d1                	mov    %dl,%cl
8010173c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010173f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101746:	89 04 24             	mov    %eax,(%esp)
80101749:	e8 c1 22 00 00       	call   80103a0f <log_write>
  brelse(bp);
8010174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101751:	89 04 24             	mov    %eax,(%esp)
80101754:	e8 d3 ea ff ff       	call   8010022c <brelse>
}
80101759:	c9                   	leave  
8010175a:	c3                   	ret    

8010175b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010175b:	55                   	push   %ebp
8010175c:	89 e5                	mov    %esp,%ebp
8010175e:	57                   	push   %edi
8010175f:	56                   	push   %esi
80101760:	53                   	push   %ebx
80101761:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
80101764:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010176b:	c7 44 24 04 05 9a 10 	movl   $0x80109a05,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
8010177a:	e8 ff 3c 00 00       	call   8010547e <initlock>
  for(i = 0; i < NINODE; i++) {
8010177f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101786:	eb 2b                	jmp    801017b3 <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
80101788:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010178b:	89 d0                	mov    %edx,%eax
8010178d:	c1 e0 03             	shl    $0x3,%eax
80101790:	01 d0                	add    %edx,%eax
80101792:	c1 e0 04             	shl    $0x4,%eax
80101795:	83 c0 30             	add    $0x30,%eax
80101798:	05 00 3f 11 80       	add    $0x80113f00,%eax
8010179d:	83 c0 10             	add    $0x10,%eax
801017a0:	c7 44 24 04 0c 9a 10 	movl   $0x80109a0c,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 90 3b 00 00       	call   80105340 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
801017b0:	ff 45 e4             	incl   -0x1c(%ebp)
801017b3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017b7:	7e cf                	jle    80101788 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
801017b9:	c7 44 24 04 e0 3e 11 	movl   $0x80113ee0,0x4(%esp)
801017c0:	80 
801017c1:	8b 45 08             	mov    0x8(%ebp),%eax
801017c4:	89 04 24             	mov    %eax,(%esp)
801017c7:	e8 f4 fc ff ff       	call   801014c0 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017cc:	a1 f8 3e 11 80       	mov    0x80113ef8,%eax
801017d1:	8b 3d f4 3e 11 80    	mov    0x80113ef4,%edi
801017d7:	8b 35 f0 3e 11 80    	mov    0x80113ef0,%esi
801017dd:	8b 1d ec 3e 11 80    	mov    0x80113eec,%ebx
801017e3:	8b 0d e8 3e 11 80    	mov    0x80113ee8,%ecx
801017e9:	8b 15 e4 3e 11 80    	mov    0x80113ee4,%edx
801017ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801017f2:	8b 15 e0 3e 11 80    	mov    0x80113ee0,%edx
801017f8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801017fc:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101800:	89 74 24 14          	mov    %esi,0x14(%esp)
80101804:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101808:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010180c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010180f:	89 44 24 08          	mov    %eax,0x8(%esp)
80101813:	89 d0                	mov    %edx,%eax
80101815:	89 44 24 04          	mov    %eax,0x4(%esp)
80101819:	c7 04 24 14 9a 10 80 	movl   $0x80109a14,(%esp)
80101820:	e8 9c eb ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101825:	83 c4 4c             	add    $0x4c,%esp
80101828:	5b                   	pop    %ebx
80101829:	5e                   	pop    %esi
8010182a:	5f                   	pop    %edi
8010182b:	5d                   	pop    %ebp
8010182c:	c3                   	ret    

8010182d <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010182d:	55                   	push   %ebp
8010182e:	89 e5                	mov    %esp,%ebp
80101830:	83 ec 28             	sub    $0x28,%esp
80101833:	8b 45 0c             	mov    0xc(%ebp),%eax
80101836:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010183a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101841:	e9 9b 00 00 00       	jmp    801018e1 <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
80101846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101849:	c1 e8 03             	shr    $0x3,%eax
8010184c:	89 c2                	mov    %eax,%edx
8010184e:	a1 f4 3e 11 80       	mov    0x80113ef4,%eax
80101853:	01 d0                	add    %edx,%eax
80101855:	89 44 24 04          	mov    %eax,0x4(%esp)
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	89 04 24             	mov    %eax,(%esp)
8010185f:	e8 51 e9 ff ff       	call   801001b5 <bread>
80101864:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101867:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010186a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010186d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101870:	83 e0 07             	and    $0x7,%eax
80101873:	c1 e0 06             	shl    $0x6,%eax
80101876:	01 d0                	add    %edx,%eax
80101878:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010187b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010187e:	8b 00                	mov    (%eax),%eax
80101880:	66 85 c0             	test   %ax,%ax
80101883:	75 4e                	jne    801018d3 <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
80101885:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
8010188c:	00 
8010188d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101894:	00 
80101895:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101898:	89 04 24             	mov    %eax,(%esp)
8010189b:	e8 62 3e 00 00       	call   80105702 <memset>
      dip->type = type;
801018a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801018a6:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
801018a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018ac:	89 04 24             	mov    %eax,(%esp)
801018af:	e8 5b 21 00 00       	call   80103a0f <log_write>
      brelse(bp);
801018b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b7:	89 04 24             	mov    %eax,(%esp)
801018ba:	e8 6d e9 ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
801018bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c2:	89 44 24 04          	mov    %eax,0x4(%esp)
801018c6:	8b 45 08             	mov    0x8(%ebp),%eax
801018c9:	89 04 24             	mov    %eax,(%esp)
801018cc:	e8 ea 00 00 00       	call   801019bb <iget>
801018d1:	eb 2a                	jmp    801018fd <ialloc+0xd0>
    }
    brelse(bp);
801018d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d6:	89 04 24             	mov    %eax,(%esp)
801018d9:	e8 4e e9 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018de:	ff 45 f4             	incl   -0xc(%ebp)
801018e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018e4:	a1 e8 3e 11 80       	mov    0x80113ee8,%eax
801018e9:	39 c2                	cmp    %eax,%edx
801018eb:	0f 82 55 ff ff ff    	jb     80101846 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801018f1:	c7 04 24 67 9a 10 80 	movl   $0x80109a67,(%esp)
801018f8:	e8 57 ec ff ff       	call   80100554 <panic>
}
801018fd:	c9                   	leave  
801018fe:	c3                   	ret    

801018ff <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018ff:	55                   	push   %ebp
80101900:	89 e5                	mov    %esp,%ebp
80101902:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101905:	8b 45 08             	mov    0x8(%ebp),%eax
80101908:	8b 40 04             	mov    0x4(%eax),%eax
8010190b:	c1 e8 03             	shr    $0x3,%eax
8010190e:	89 c2                	mov    %eax,%edx
80101910:	a1 f4 3e 11 80       	mov    0x80113ef4,%eax
80101915:	01 c2                	add    %eax,%edx
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	8b 00                	mov    (%eax),%eax
8010191c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101920:	89 04 24             	mov    %eax,(%esp)
80101923:	e8 8d e8 ff ff       	call   801001b5 <bread>
80101928:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010192e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101931:	8b 45 08             	mov    0x8(%ebp),%eax
80101934:	8b 40 04             	mov    0x4(%eax),%eax
80101937:	83 e0 07             	and    $0x7,%eax
8010193a:	c1 e0 06             	shl    $0x6,%eax
8010193d:	01 d0                	add    %edx,%eax
8010193f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101942:	8b 45 08             	mov    0x8(%ebp),%eax
80101945:	8b 40 50             	mov    0x50(%eax),%eax
80101948:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010194b:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
8010194e:	8b 45 08             	mov    0x8(%ebp),%eax
80101951:	66 8b 40 52          	mov    0x52(%eax),%ax
80101955:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101958:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
8010195c:	8b 45 08             	mov    0x8(%ebp),%eax
8010195f:	8b 40 54             	mov    0x54(%eax),%eax
80101962:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101965:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
80101969:	8b 45 08             	mov    0x8(%ebp),%eax
8010196c:	66 8b 40 56          	mov    0x56(%eax),%ax
80101970:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101973:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
80101977:	8b 45 08             	mov    0x8(%ebp),%eax
8010197a:	8b 50 58             	mov    0x58(%eax),%edx
8010197d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101980:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101983:	8b 45 08             	mov    0x8(%ebp),%eax
80101986:	8d 50 5c             	lea    0x5c(%eax),%edx
80101989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010198c:	83 c0 0c             	add    $0xc,%eax
8010198f:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101996:	00 
80101997:	89 54 24 04          	mov    %edx,0x4(%esp)
8010199b:	89 04 24             	mov    %eax,(%esp)
8010199e:	e8 28 3e 00 00       	call   801057cb <memmove>
  log_write(bp);
801019a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a6:	89 04 24             	mov    %eax,(%esp)
801019a9:	e8 61 20 00 00       	call   80103a0f <log_write>
  brelse(bp);
801019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b1:	89 04 24             	mov    %eax,(%esp)
801019b4:	e8 73 e8 ff ff       	call   8010022c <brelse>
}
801019b9:	c9                   	leave  
801019ba:	c3                   	ret    

801019bb <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801019bb:	55                   	push   %ebp
801019bc:	89 e5                	mov    %esp,%ebp
801019be:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801019c1:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
801019c8:	e8 d2 3a 00 00       	call   8010549f <acquire>

  // Is the inode already cached?
  empty = 0;
801019cd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019d4:	c7 45 f4 34 3f 11 80 	movl   $0x80113f34,-0xc(%ebp)
801019db:	eb 5c                	jmp    80101a39 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e0:	8b 40 08             	mov    0x8(%eax),%eax
801019e3:	85 c0                	test   %eax,%eax
801019e5:	7e 35                	jle    80101a1c <iget+0x61>
801019e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ea:	8b 00                	mov    (%eax),%eax
801019ec:	3b 45 08             	cmp    0x8(%ebp),%eax
801019ef:	75 2b                	jne    80101a1c <iget+0x61>
801019f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f4:	8b 40 04             	mov    0x4(%eax),%eax
801019f7:	3b 45 0c             	cmp    0xc(%ebp),%eax
801019fa:	75 20                	jne    80101a1c <iget+0x61>
      ip->ref++;
801019fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ff:	8b 40 08             	mov    0x8(%eax),%eax
80101a02:	8d 50 01             	lea    0x1(%eax),%edx
80101a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a08:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a0b:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101a12:	e8 f2 3a 00 00       	call   80105509 <release>
      return ip;
80101a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a1a:	eb 72                	jmp    80101a8e <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a20:	75 10                	jne    80101a32 <iget+0x77>
80101a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a25:	8b 40 08             	mov    0x8(%eax),%eax
80101a28:	85 c0                	test   %eax,%eax
80101a2a:	75 06                	jne    80101a32 <iget+0x77>
      empty = ip;
80101a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a32:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a39:	81 7d f4 54 5b 11 80 	cmpl   $0x80115b54,-0xc(%ebp)
80101a40:	72 9b                	jb     801019dd <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a42:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a46:	75 0c                	jne    80101a54 <iget+0x99>
    panic("iget: no inodes");
80101a48:	c7 04 24 79 9a 10 80 	movl   $0x80109a79,(%esp)
80101a4f:	e8 00 eb ff ff       	call   80100554 <panic>

  ip = empty;
80101a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a57:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5d:	8b 55 08             	mov    0x8(%ebp),%edx
80101a60:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a65:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a68:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a78:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a7f:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101a86:	e8 7e 3a 00 00       	call   80105509 <release>

  return ip;
80101a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a8e:	c9                   	leave  
80101a8f:	c3                   	ret    

80101a90 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a90:	55                   	push   %ebp
80101a91:	89 e5                	mov    %esp,%ebp
80101a93:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a96:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101a9d:	e8 fd 39 00 00       	call   8010549f <acquire>
  ip->ref++;
80101aa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa5:	8b 40 08             	mov    0x8(%eax),%eax
80101aa8:	8d 50 01             	lea    0x1(%eax),%edx
80101aab:	8b 45 08             	mov    0x8(%ebp),%eax
80101aae:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101ab1:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101ab8:	e8 4c 3a 00 00       	call   80105509 <release>
  return ip;
80101abd:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101ac0:	c9                   	leave  
80101ac1:	c3                   	ret    

80101ac2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101ac2:	55                   	push   %ebp
80101ac3:	89 e5                	mov    %esp,%ebp
80101ac5:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101ac8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101acc:	74 0a                	je     80101ad8 <ilock+0x16>
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	8b 40 08             	mov    0x8(%eax),%eax
80101ad4:	85 c0                	test   %eax,%eax
80101ad6:	7f 0c                	jg     80101ae4 <ilock+0x22>
    panic("ilock");
80101ad8:	c7 04 24 89 9a 10 80 	movl   $0x80109a89,(%esp)
80101adf:	e8 70 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae7:	83 c0 0c             	add    $0xc,%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 88 38 00 00       	call   8010537a <acquiresleep>

  if(ip->valid == 0){
80101af2:	8b 45 08             	mov    0x8(%ebp),%eax
80101af5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101af8:	85 c0                	test   %eax,%eax
80101afa:	0f 85 ca 00 00 00    	jne    80101bca <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	8b 40 04             	mov    0x4(%eax),%eax
80101b06:	c1 e8 03             	shr    $0x3,%eax
80101b09:	89 c2                	mov    %eax,%edx
80101b0b:	a1 f4 3e 11 80       	mov    0x80113ef4,%eax
80101b10:	01 c2                	add    %eax,%edx
80101b12:	8b 45 08             	mov    0x8(%ebp),%eax
80101b15:	8b 00                	mov    (%eax),%eax
80101b17:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b1b:	89 04 24             	mov    %eax,(%esp)
80101b1e:	e8 92 e6 ff ff       	call   801001b5 <bread>
80101b23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b29:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2f:	8b 40 04             	mov    0x4(%eax),%eax
80101b32:	83 e0 07             	and    $0x7,%eax
80101b35:	c1 e0 06             	shl    $0x6,%eax
80101b38:	01 d0                	add    %edx,%eax
80101b3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b40:	8b 00                	mov    (%eax),%eax
80101b42:	8b 55 08             	mov    0x8(%ebp),%edx
80101b45:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101b49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b4c:	66 8b 40 02          	mov    0x2(%eax),%ax
80101b50:	8b 55 08             	mov    0x8(%ebp),%edx
80101b53:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101b57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5a:	8b 40 04             	mov    0x4(%eax),%eax
80101b5d:	8b 55 08             	mov    0x8(%ebp),%edx
80101b60:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b67:	66 8b 40 06          	mov    0x6(%eax),%ax
80101b6b:	8b 55 08             	mov    0x8(%ebp),%edx
80101b6e:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b75:	8b 50 08             	mov    0x8(%eax),%edx
80101b78:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7b:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b81:	8d 50 0c             	lea    0xc(%eax),%edx
80101b84:	8b 45 08             	mov    0x8(%ebp),%eax
80101b87:	83 c0 5c             	add    $0x5c,%eax
80101b8a:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101b91:	00 
80101b92:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b96:	89 04 24             	mov    %eax,(%esp)
80101b99:	e8 2d 3c 00 00       	call   801057cb <memmove>
    brelse(bp);
80101b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ba1:	89 04 24             	mov    %eax,(%esp)
80101ba4:	e8 83 e6 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101bb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb6:	8b 40 50             	mov    0x50(%eax),%eax
80101bb9:	66 85 c0             	test   %ax,%ax
80101bbc:	75 0c                	jne    80101bca <ilock+0x108>
      panic("ilock: no type");
80101bbe:	c7 04 24 8f 9a 10 80 	movl   $0x80109a8f,(%esp)
80101bc5:	e8 8a e9 ff ff       	call   80100554 <panic>
  }
}
80101bca:	c9                   	leave  
80101bcb:	c3                   	ret    

80101bcc <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101bcc:	55                   	push   %ebp
80101bcd:	89 e5                	mov    %esp,%ebp
80101bcf:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bd2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bd6:	74 1c                	je     80101bf4 <iunlock+0x28>
80101bd8:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdb:	83 c0 0c             	add    $0xc,%eax
80101bde:	89 04 24             	mov    %eax,(%esp)
80101be1:	e8 31 38 00 00       	call   80105417 <holdingsleep>
80101be6:	85 c0                	test   %eax,%eax
80101be8:	74 0a                	je     80101bf4 <iunlock+0x28>
80101bea:	8b 45 08             	mov    0x8(%ebp),%eax
80101bed:	8b 40 08             	mov    0x8(%eax),%eax
80101bf0:	85 c0                	test   %eax,%eax
80101bf2:	7f 0c                	jg     80101c00 <iunlock+0x34>
    panic("iunlock");
80101bf4:	c7 04 24 9e 9a 10 80 	movl   $0x80109a9e,(%esp)
80101bfb:	e8 54 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	83 c0 0c             	add    $0xc,%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 c7 37 00 00       	call   801053d5 <releasesleep>
}
80101c0e:	c9                   	leave  
80101c0f:	c3                   	ret    

80101c10 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c10:	55                   	push   %ebp
80101c11:	89 e5                	mov    %esp,%ebp
80101c13:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101c16:	8b 45 08             	mov    0x8(%ebp),%eax
80101c19:	83 c0 0c             	add    $0xc,%eax
80101c1c:	89 04 24             	mov    %eax,(%esp)
80101c1f:	e8 56 37 00 00       	call   8010537a <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101c24:	8b 45 08             	mov    0x8(%ebp),%eax
80101c27:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c2a:	85 c0                	test   %eax,%eax
80101c2c:	74 5c                	je     80101c8a <iput+0x7a>
80101c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c31:	66 8b 40 56          	mov    0x56(%eax),%ax
80101c35:	66 85 c0             	test   %ax,%ax
80101c38:	75 50                	jne    80101c8a <iput+0x7a>
    acquire(&icache.lock);
80101c3a:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c41:	e8 59 38 00 00       	call   8010549f <acquire>
    int r = ip->ref;
80101c46:	8b 45 08             	mov    0x8(%ebp),%eax
80101c49:	8b 40 08             	mov    0x8(%eax),%eax
80101c4c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c4f:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c56:	e8 ae 38 00 00       	call   80105509 <release>
    if(r == 1){
80101c5b:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c5f:	75 29                	jne    80101c8a <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c61:	8b 45 08             	mov    0x8(%ebp),%eax
80101c64:	89 04 24             	mov    %eax,(%esp)
80101c67:	e8 86 01 00 00       	call   80101df2 <itrunc>
      ip->type = 0;
80101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6f:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c75:	8b 45 08             	mov    0x8(%ebp),%eax
80101c78:	89 04 24             	mov    %eax,(%esp)
80101c7b:	e8 7f fc ff ff       	call   801018ff <iupdate>
      ip->valid = 0;
80101c80:	8b 45 08             	mov    0x8(%ebp),%eax
80101c83:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8d:	83 c0 0c             	add    $0xc,%eax
80101c90:	89 04 24             	mov    %eax,(%esp)
80101c93:	e8 3d 37 00 00       	call   801053d5 <releasesleep>

  acquire(&icache.lock);
80101c98:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101c9f:	e8 fb 37 00 00       	call   8010549f <acquire>
  ip->ref--;
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 40 08             	mov    0x8(%eax),%eax
80101caa:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cad:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb0:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cb3:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80101cba:	e8 4a 38 00 00       	call   80105509 <release>
}
80101cbf:	c9                   	leave  
80101cc0:	c3                   	ret    

80101cc1 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cc1:	55                   	push   %ebp
80101cc2:	89 e5                	mov    %esp,%ebp
80101cc4:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101cc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cca:	89 04 24             	mov    %eax,(%esp)
80101ccd:	e8 fa fe ff ff       	call   80101bcc <iunlock>
  iput(ip);
80101cd2:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd5:	89 04 24             	mov    %eax,(%esp)
80101cd8:	e8 33 ff ff ff       	call   80101c10 <iput>
}
80101cdd:	c9                   	leave  
80101cde:	c3                   	ret    

80101cdf <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cdf:	55                   	push   %ebp
80101ce0:	89 e5                	mov    %esp,%ebp
80101ce2:	53                   	push   %ebx
80101ce3:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101ce6:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cea:	77 3e                	ja     80101d2a <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101cec:	8b 45 08             	mov    0x8(%ebp),%eax
80101cef:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cf2:	83 c2 14             	add    $0x14,%edx
80101cf5:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d00:	75 20                	jne    80101d22 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d02:	8b 45 08             	mov    0x8(%ebp),%eax
80101d05:	8b 00                	mov    (%eax),%eax
80101d07:	89 04 24             	mov    %eax,(%esp)
80101d0a:	e8 48 f8 ff ff       	call   80101557 <balloc>
80101d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d12:	8b 45 08             	mov    0x8(%ebp),%eax
80101d15:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d18:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d1e:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d25:	e9 c2 00 00 00       	jmp    80101dec <bmap+0x10d>
  }
  bn -= NDIRECT;
80101d2a:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d2e:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d32:	0f 87 a8 00 00 00    	ja     80101de0 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d38:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3b:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d44:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d48:	75 1c                	jne    80101d66 <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4d:	8b 00                	mov    (%eax),%eax
80101d4f:	89 04 24             	mov    %eax,(%esp)
80101d52:	e8 00 f8 ff ff       	call   80101557 <balloc>
80101d57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
80101d5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d60:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d66:	8b 45 08             	mov    0x8(%ebp),%eax
80101d69:	8b 00                	mov    (%eax),%eax
80101d6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d72:	89 04 24             	mov    %eax,(%esp)
80101d75:	e8 3b e4 ff ff       	call   801001b5 <bread>
80101d7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d80:	83 c0 5c             	add    $0x5c,%eax
80101d83:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d86:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d89:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d93:	01 d0                	add    %edx,%eax
80101d95:	8b 00                	mov    (%eax),%eax
80101d97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d9e:	75 30                	jne    80101dd0 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101da0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101da3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101daa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dad:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101db0:	8b 45 08             	mov    0x8(%ebp),%eax
80101db3:	8b 00                	mov    (%eax),%eax
80101db5:	89 04 24             	mov    %eax,(%esp)
80101db8:	e8 9a f7 ff ff       	call   80101557 <balloc>
80101dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dc3:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101dc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dc8:	89 04 24             	mov    %eax,(%esp)
80101dcb:	e8 3f 1c 00 00       	call   80103a0f <log_write>
    }
    brelse(bp);
80101dd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dd3:	89 04 24             	mov    %eax,(%esp)
80101dd6:	e8 51 e4 ff ff       	call   8010022c <brelse>
    return addr;
80101ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dde:	eb 0c                	jmp    80101dec <bmap+0x10d>
  }

  panic("bmap: out of range");
80101de0:	c7 04 24 a6 9a 10 80 	movl   $0x80109aa6,(%esp)
80101de7:	e8 68 e7 ff ff       	call   80100554 <panic>
}
80101dec:	83 c4 24             	add    $0x24,%esp
80101def:	5b                   	pop    %ebx
80101df0:	5d                   	pop    %ebp
80101df1:	c3                   	ret    

80101df2 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101df2:	55                   	push   %ebp
80101df3:	89 e5                	mov    %esp,%ebp
80101df5:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101df8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101dff:	eb 43                	jmp    80101e44 <itrunc+0x52>
    if(ip->addrs[i]){
80101e01:	8b 45 08             	mov    0x8(%ebp),%eax
80101e04:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e07:	83 c2 14             	add    $0x14,%edx
80101e0a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e0e:	85 c0                	test   %eax,%eax
80101e10:	74 2f                	je     80101e41 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101e12:	8b 45 08             	mov    0x8(%ebp),%eax
80101e15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e18:	83 c2 14             	add    $0x14,%edx
80101e1b:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e22:	8b 00                	mov    (%eax),%eax
80101e24:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e28:	89 04 24             	mov    %eax,(%esp)
80101e2b:	e8 61 f8 ff ff       	call   80101691 <bfree>
      ip->addrs[i] = 0;
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e36:	83 c2 14             	add    $0x14,%edx
80101e39:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e40:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e41:	ff 45 f4             	incl   -0xc(%ebp)
80101e44:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e48:	7e b7                	jle    80101e01 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4d:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e53:	85 c0                	test   %eax,%eax
80101e55:	0f 84 a3 00 00 00    	je     80101efe <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5e:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 00                	mov    (%eax),%eax
80101e69:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e6d:	89 04 24             	mov    %eax,(%esp)
80101e70:	e8 40 e3 ff ff       	call   801001b5 <bread>
80101e75:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e7b:	83 c0 5c             	add    $0x5c,%eax
80101e7e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e81:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e88:	eb 3a                	jmp    80101ec4 <itrunc+0xd2>
      if(a[j])
80101e8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e94:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e97:	01 d0                	add    %edx,%eax
80101e99:	8b 00                	mov    (%eax),%eax
80101e9b:	85 c0                	test   %eax,%eax
80101e9d:	74 22                	je     80101ec1 <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101e9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ea9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eac:	01 d0                	add    %edx,%eax
80101eae:	8b 10                	mov    (%eax),%edx
80101eb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb3:	8b 00                	mov    (%eax),%eax
80101eb5:	89 54 24 04          	mov    %edx,0x4(%esp)
80101eb9:	89 04 24             	mov    %eax,(%esp)
80101ebc:	e8 d0 f7 ff ff       	call   80101691 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101ec1:	ff 45 f0             	incl   -0x10(%ebp)
80101ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec7:	83 f8 7f             	cmp    $0x7f,%eax
80101eca:	76 be                	jbe    80101e8a <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ecf:	89 04 24             	mov    %eax,(%esp)
80101ed2:	e8 55 e3 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ed7:	8b 45 08             	mov    0x8(%ebp),%eax
80101eda:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ee0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee3:	8b 00                	mov    (%eax),%eax
80101ee5:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ee9:	89 04 24             	mov    %eax,(%esp)
80101eec:	e8 a0 f7 ff ff       	call   80101691 <bfree>
    ip->addrs[NDIRECT] = 0;
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101efb:	00 00 00 
  }

  ip->size = 0;
80101efe:	8b 45 08             	mov    0x8(%ebp),%eax
80101f01:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f08:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0b:	89 04 24             	mov    %eax,(%esp)
80101f0e:	e8 ec f9 ff ff       	call   801018ff <iupdate>
}
80101f13:	c9                   	leave  
80101f14:	c3                   	ret    

80101f15 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f15:	55                   	push   %ebp
80101f16:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f18:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1b:	8b 00                	mov    (%eax),%eax
80101f1d:	89 c2                	mov    %eax,%edx
80101f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f22:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f25:	8b 45 08             	mov    0x8(%ebp),%eax
80101f28:	8b 50 04             	mov    0x4(%eax),%edx
80101f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f2e:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f31:	8b 45 08             	mov    0x8(%ebp),%eax
80101f34:	8b 40 50             	mov    0x50(%eax),%eax
80101f37:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f3a:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f40:	66 8b 40 56          	mov    0x56(%eax),%ax
80101f44:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f47:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4e:	8b 50 58             	mov    0x58(%eax),%edx
80101f51:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f54:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f57:	5d                   	pop    %ebp
80101f58:	c3                   	ret    

80101f59 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f59:	55                   	push   %ebp
80101f5a:	89 e5                	mov    %esp,%ebp
80101f5c:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f62:	8b 40 50             	mov    0x50(%eax),%eax
80101f65:	66 83 f8 03          	cmp    $0x3,%ax
80101f69:	75 60                	jne    80101fcb <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6e:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f72:	66 85 c0             	test   %ax,%ax
80101f75:	78 20                	js     80101f97 <readi+0x3e>
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f7e:	66 83 f8 09          	cmp    $0x9,%ax
80101f82:	7f 13                	jg     80101f97 <readi+0x3e>
80101f84:	8b 45 08             	mov    0x8(%ebp),%eax
80101f87:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f8b:	98                   	cwtl   
80101f8c:	8b 04 c5 80 3e 11 80 	mov    -0x7feec180(,%eax,8),%eax
80101f93:	85 c0                	test   %eax,%eax
80101f95:	75 0a                	jne    80101fa1 <readi+0x48>
      return -1;
80101f97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f9c:	e9 1a 01 00 00       	jmp    801020bb <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101fa1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa4:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fa8:	98                   	cwtl   
80101fa9:	8b 04 c5 80 3e 11 80 	mov    -0x7feec180(,%eax,8),%eax
80101fb0:	8b 55 14             	mov    0x14(%ebp),%edx
80101fb3:	89 54 24 08          	mov    %edx,0x8(%esp)
80101fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fba:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fbe:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc1:	89 14 24             	mov    %edx,(%esp)
80101fc4:	ff d0                	call   *%eax
80101fc6:	e9 f0 00 00 00       	jmp    801020bb <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101fcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fce:	8b 40 58             	mov    0x58(%eax),%eax
80101fd1:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fd4:	72 0d                	jb     80101fe3 <readi+0x8a>
80101fd6:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd9:	8b 55 10             	mov    0x10(%ebp),%edx
80101fdc:	01 d0                	add    %edx,%eax
80101fde:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fe1:	73 0a                	jae    80101fed <readi+0x94>
    return -1;
80101fe3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fe8:	e9 ce 00 00 00       	jmp    801020bb <readi+0x162>
  if(off + n > ip->size)
80101fed:	8b 45 14             	mov    0x14(%ebp),%eax
80101ff0:	8b 55 10             	mov    0x10(%ebp),%edx
80101ff3:	01 c2                	add    %eax,%edx
80101ff5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff8:	8b 40 58             	mov    0x58(%eax),%eax
80101ffb:	39 c2                	cmp    %eax,%edx
80101ffd:	76 0c                	jbe    8010200b <readi+0xb2>
    n = ip->size - off;
80101fff:	8b 45 08             	mov    0x8(%ebp),%eax
80102002:	8b 40 58             	mov    0x58(%eax),%eax
80102005:	2b 45 10             	sub    0x10(%ebp),%eax
80102008:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010200b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102012:	e9 95 00 00 00       	jmp    801020ac <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102017:	8b 45 10             	mov    0x10(%ebp),%eax
8010201a:	c1 e8 09             	shr    $0x9,%eax
8010201d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102021:	8b 45 08             	mov    0x8(%ebp),%eax
80102024:	89 04 24             	mov    %eax,(%esp)
80102027:	e8 b3 fc ff ff       	call   80101cdf <bmap>
8010202c:	8b 55 08             	mov    0x8(%ebp),%edx
8010202f:	8b 12                	mov    (%edx),%edx
80102031:	89 44 24 04          	mov    %eax,0x4(%esp)
80102035:	89 14 24             	mov    %edx,(%esp)
80102038:	e8 78 e1 ff ff       	call   801001b5 <bread>
8010203d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102040:	8b 45 10             	mov    0x10(%ebp),%eax
80102043:	25 ff 01 00 00       	and    $0x1ff,%eax
80102048:	89 c2                	mov    %eax,%edx
8010204a:	b8 00 02 00 00       	mov    $0x200,%eax
8010204f:	29 d0                	sub    %edx,%eax
80102051:	89 c1                	mov    %eax,%ecx
80102053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102056:	8b 55 14             	mov    0x14(%ebp),%edx
80102059:	29 c2                	sub    %eax,%edx
8010205b:	89 c8                	mov    %ecx,%eax
8010205d:	39 d0                	cmp    %edx,%eax
8010205f:	76 02                	jbe    80102063 <readi+0x10a>
80102061:	89 d0                	mov    %edx,%eax
80102063:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102066:	8b 45 10             	mov    0x10(%ebp),%eax
80102069:	25 ff 01 00 00       	and    $0x1ff,%eax
8010206e:	8d 50 50             	lea    0x50(%eax),%edx
80102071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102074:	01 d0                	add    %edx,%eax
80102076:	8d 50 0c             	lea    0xc(%eax),%edx
80102079:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010207c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102080:	89 54 24 04          	mov    %edx,0x4(%esp)
80102084:	8b 45 0c             	mov    0xc(%ebp),%eax
80102087:	89 04 24             	mov    %eax,(%esp)
8010208a:	e8 3c 37 00 00       	call   801057cb <memmove>
    brelse(bp);
8010208f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102092:	89 04 24             	mov    %eax,(%esp)
80102095:	e8 92 e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010209a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010209d:	01 45 f4             	add    %eax,-0xc(%ebp)
801020a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a3:	01 45 10             	add    %eax,0x10(%ebp)
801020a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020a9:	01 45 0c             	add    %eax,0xc(%ebp)
801020ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020af:	3b 45 14             	cmp    0x14(%ebp),%eax
801020b2:	0f 82 5f ff ff ff    	jb     80102017 <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
801020b8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020bb:	c9                   	leave  
801020bc:	c3                   	ret    

801020bd <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020bd:	55                   	push   %ebp
801020be:	89 e5                	mov    %esp,%ebp
801020c0:	83 ec 38             	sub    $0x38,%esp
  uint tot, m;
  struct buf *bp;
  struct container* cont = myproc()->cont;
801020c3:	e8 6b 24 00 00       	call   80104533 <myproc>
801020c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801020ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int x = find(cont->name); // should be in range of 0-MAX_CONTAINERS to be utilized
801020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d4:	83 c0 18             	add    $0x18,%eax
801020d7:	89 04 24             	mov    %eax,(%esp)
801020da:	e8 04 71 00 00       	call   801091e3 <find>
801020df:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if(ip->type == T_DEV){
801020e2:	8b 45 08             	mov    0x8(%ebp),%eax
801020e5:	8b 40 50             	mov    0x50(%eax),%eax
801020e8:	66 83 f8 03          	cmp    $0x3,%ax
801020ec:	75 60                	jne    8010214e <writei+0x91>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write){
801020ee:	8b 45 08             	mov    0x8(%ebp),%eax
801020f1:	66 8b 40 52          	mov    0x52(%eax),%ax
801020f5:	66 85 c0             	test   %ax,%ax
801020f8:	78 20                	js     8010211a <writei+0x5d>
801020fa:	8b 45 08             	mov    0x8(%ebp),%eax
801020fd:	66 8b 40 52          	mov    0x52(%eax),%ax
80102101:	66 83 f8 09          	cmp    $0x9,%ax
80102105:	7f 13                	jg     8010211a <writei+0x5d>
80102107:	8b 45 08             	mov    0x8(%ebp),%eax
8010210a:	66 8b 40 52          	mov    0x52(%eax),%ax
8010210e:	98                   	cwtl   
8010210f:	8b 04 c5 84 3e 11 80 	mov    -0x7feec17c(,%eax,8),%eax
80102116:	85 c0                	test   %eax,%eax
80102118:	75 0a                	jne    80102124 <writei+0x67>
      return -1;
8010211a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010211f:	e9 64 01 00 00       	jmp    80102288 <writei+0x1cb>
    }
    return devsw[ip->major].write(ip, src, n);
80102124:	8b 45 08             	mov    0x8(%ebp),%eax
80102127:	66 8b 40 52          	mov    0x52(%eax),%ax
8010212b:	98                   	cwtl   
8010212c:	8b 04 c5 84 3e 11 80 	mov    -0x7feec17c(,%eax,8),%eax
80102133:	8b 55 14             	mov    0x14(%ebp),%edx
80102136:	89 54 24 08          	mov    %edx,0x8(%esp)
8010213a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010213d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102141:	8b 55 08             	mov    0x8(%ebp),%edx
80102144:	89 14 24             	mov    %edx,(%esp)
80102147:	ff d0                	call   *%eax
80102149:	e9 3a 01 00 00       	jmp    80102288 <writei+0x1cb>
  }


  if(off > ip->size || off + n < off){
8010214e:	8b 45 08             	mov    0x8(%ebp),%eax
80102151:	8b 40 58             	mov    0x58(%eax),%eax
80102154:	3b 45 10             	cmp    0x10(%ebp),%eax
80102157:	72 0d                	jb     80102166 <writei+0xa9>
80102159:	8b 45 14             	mov    0x14(%ebp),%eax
8010215c:	8b 55 10             	mov    0x10(%ebp),%edx
8010215f:	01 d0                	add    %edx,%eax
80102161:	3b 45 10             	cmp    0x10(%ebp),%eax
80102164:	73 0a                	jae    80102170 <writei+0xb3>
    return -1;
80102166:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010216b:	e9 18 01 00 00       	jmp    80102288 <writei+0x1cb>
  }
  if(off + n > MAXFILE*BSIZE){
80102170:	8b 45 14             	mov    0x14(%ebp),%eax
80102173:	8b 55 10             	mov    0x10(%ebp),%edx
80102176:	01 d0                	add    %edx,%eax
80102178:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010217d:	76 0a                	jbe    80102189 <writei+0xcc>
    return -1;
8010217f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102184:	e9 ff 00 00 00       	jmp    80102288 <writei+0x1cb>
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102189:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102190:	e9 a0 00 00 00       	jmp    80102235 <writei+0x178>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102195:	8b 45 10             	mov    0x10(%ebp),%eax
80102198:	c1 e8 09             	shr    $0x9,%eax
8010219b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010219f:	8b 45 08             	mov    0x8(%ebp),%eax
801021a2:	89 04 24             	mov    %eax,(%esp)
801021a5:	e8 35 fb ff ff       	call   80101cdf <bmap>
801021aa:	8b 55 08             	mov    0x8(%ebp),%edx
801021ad:	8b 12                	mov    (%edx),%edx
801021af:	89 44 24 04          	mov    %eax,0x4(%esp)
801021b3:	89 14 24             	mov    %edx,(%esp)
801021b6:	e8 fa df ff ff       	call   801001b5 <bread>
801021bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021be:	8b 45 10             	mov    0x10(%ebp),%eax
801021c1:	25 ff 01 00 00       	and    $0x1ff,%eax
801021c6:	89 c2                	mov    %eax,%edx
801021c8:	b8 00 02 00 00       	mov    $0x200,%eax
801021cd:	29 d0                	sub    %edx,%eax
801021cf:	89 c1                	mov    %eax,%ecx
801021d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021d4:	8b 55 14             	mov    0x14(%ebp),%edx
801021d7:	29 c2                	sub    %eax,%edx
801021d9:	89 c8                	mov    %ecx,%eax
801021db:	39 d0                	cmp    %edx,%eax
801021dd:	76 02                	jbe    801021e1 <writei+0x124>
801021df:	89 d0                	mov    %edx,%eax
801021e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021e4:	8b 45 10             	mov    0x10(%ebp),%eax
801021e7:	25 ff 01 00 00       	and    $0x1ff,%eax
801021ec:	8d 50 50             	lea    0x50(%eax),%edx
801021ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801021f2:	01 d0                	add    %edx,%eax
801021f4:	8d 50 0c             	lea    0xc(%eax),%edx
801021f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801021fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801021fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80102201:	89 44 24 04          	mov    %eax,0x4(%esp)
80102205:	89 14 24             	mov    %edx,(%esp)
80102208:	e8 be 35 00 00       	call   801057cb <memmove>
    log_write(bp);
8010220d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102210:	89 04 24             	mov    %eax,(%esp)
80102213:	e8 f7 17 00 00       	call   80103a0f <log_write>
    brelse(bp);
80102218:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010221b:	89 04 24             	mov    %eax,(%esp)
8010221e:	e8 09 e0 ff ff       	call   8010022c <brelse>
  }
  if(off + n > MAXFILE*BSIZE){
    return -1;
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102226:	01 45 f4             	add    %eax,-0xc(%ebp)
80102229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010222c:	01 45 10             	add    %eax,0x10(%ebp)
8010222f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102232:	01 45 0c             	add    %eax,0xc(%ebp)
80102235:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102238:	3b 45 14             	cmp    0x14(%ebp),%eax
8010223b:	0f 82 54 ff ff ff    	jb     80102195 <writei+0xd8>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(x >= 0){
80102241:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80102245:	78 19                	js     80102260 <writei+0x1a3>
    if(tot == 1){
80102247:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010224b:	75 13                	jne    80102260 <writei+0x1a3>
      set_curr_disk(1, x);
8010224d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102250:	89 44 24 04          	mov    %eax,0x4(%esp)
80102254:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010225b:	e8 18 73 00 00       	call   80109578 <set_curr_disk>
    }
  }
  if(n > 0 && off > ip->size){
80102260:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102264:	74 1f                	je     80102285 <writei+0x1c8>
80102266:	8b 45 08             	mov    0x8(%ebp),%eax
80102269:	8b 40 58             	mov    0x58(%eax),%eax
8010226c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010226f:	73 14                	jae    80102285 <writei+0x1c8>
    ip->size = off;
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 55 10             	mov    0x10(%ebp),%edx
80102277:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
8010227a:	8b 45 08             	mov    0x8(%ebp),%eax
8010227d:	89 04 24             	mov    %eax,(%esp)
80102280:	e8 7a f6 ff ff       	call   801018ff <iupdate>
  }
  return n;
80102285:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102288:	c9                   	leave  
80102289:	c3                   	ret    

8010228a <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010228a:	55                   	push   %ebp
8010228b:	89 e5                	mov    %esp,%ebp
8010228d:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
80102290:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102297:	00 
80102298:	8b 45 0c             	mov    0xc(%ebp),%eax
8010229b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010229f:	8b 45 08             	mov    0x8(%ebp),%eax
801022a2:	89 04 24             	mov    %eax,(%esp)
801022a5:	e8 c0 35 00 00       	call   8010586a <strncmp>
}
801022aa:	c9                   	leave  
801022ab:	c3                   	ret    

801022ac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801022ac:	55                   	push   %ebp
801022ad:	89 e5                	mov    %esp,%ebp
801022af:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022b2:	8b 45 08             	mov    0x8(%ebp),%eax
801022b5:	8b 40 50             	mov    0x50(%eax),%eax
801022b8:	66 83 f8 01          	cmp    $0x1,%ax
801022bc:	74 0c                	je     801022ca <dirlookup+0x1e>
    panic("dirlookup not DIR");
801022be:	c7 04 24 b9 9a 10 80 	movl   $0x80109ab9,(%esp)
801022c5:	e8 8a e2 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022d1:	e9 86 00 00 00       	jmp    8010235c <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022dd:	00 
801022de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e1:	89 44 24 08          	mov    %eax,0x8(%esp)
801022e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ec:	8b 45 08             	mov    0x8(%ebp),%eax
801022ef:	89 04 24             	mov    %eax,(%esp)
801022f2:	e8 62 fc ff ff       	call   80101f59 <readi>
801022f7:	83 f8 10             	cmp    $0x10,%eax
801022fa:	74 0c                	je     80102308 <dirlookup+0x5c>
      panic("dirlookup read");
801022fc:	c7 04 24 cb 9a 10 80 	movl   $0x80109acb,(%esp)
80102303:	e8 4c e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102308:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010230b:	66 85 c0             	test   %ax,%ax
8010230e:	75 02                	jne    80102312 <dirlookup+0x66>
      continue;
80102310:	eb 46                	jmp    80102358 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
80102312:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102315:	83 c0 02             	add    $0x2,%eax
80102318:	89 44 24 04          	mov    %eax,0x4(%esp)
8010231c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010231f:	89 04 24             	mov    %eax,(%esp)
80102322:	e8 63 ff ff ff       	call   8010228a <namecmp>
80102327:	85 c0                	test   %eax,%eax
80102329:	75 2d                	jne    80102358 <dirlookup+0xac>
      // entry matches path element
      if(poff)
8010232b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010232f:	74 08                	je     80102339 <dirlookup+0x8d>
        *poff = off;
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102337:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102339:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010233c:	0f b7 c0             	movzwl %ax,%eax
8010233f:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102342:	8b 45 08             	mov    0x8(%ebp),%eax
80102345:	8b 00                	mov    (%eax),%eax
80102347:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010234a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010234e:	89 04 24             	mov    %eax,(%esp)
80102351:	e8 65 f6 ff ff       	call   801019bb <iget>
80102356:	eb 18                	jmp    80102370 <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102358:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010235c:	8b 45 08             	mov    0x8(%ebp),%eax
8010235f:	8b 40 58             	mov    0x58(%eax),%eax
80102362:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102365:	0f 87 6b ff ff ff    	ja     801022d6 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010236b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102370:	c9                   	leave  
80102371:	c3                   	ret    

80102372 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102372:	55                   	push   %ebp
80102373:	89 e5                	mov    %esp,%ebp
80102375:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102378:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010237f:	00 
80102380:	8b 45 0c             	mov    0xc(%ebp),%eax
80102383:	89 44 24 04          	mov    %eax,0x4(%esp)
80102387:	8b 45 08             	mov    0x8(%ebp),%eax
8010238a:	89 04 24             	mov    %eax,(%esp)
8010238d:	e8 1a ff ff ff       	call   801022ac <dirlookup>
80102392:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102395:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102399:	74 15                	je     801023b0 <dirlink+0x3e>
    iput(ip);
8010239b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010239e:	89 04 24             	mov    %eax,(%esp)
801023a1:	e8 6a f8 ff ff       	call   80101c10 <iput>
    return -1;
801023a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023ab:	e9 b6 00 00 00       	jmp    80102466 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801023b7:	eb 45                	jmp    801023fe <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023bc:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023c3:	00 
801023c4:	89 44 24 08          	mov    %eax,0x8(%esp)
801023c8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801023cf:	8b 45 08             	mov    0x8(%ebp),%eax
801023d2:	89 04 24             	mov    %eax,(%esp)
801023d5:	e8 7f fb ff ff       	call   80101f59 <readi>
801023da:	83 f8 10             	cmp    $0x10,%eax
801023dd:	74 0c                	je     801023eb <dirlink+0x79>
      panic("dirlink read");
801023df:	c7 04 24 da 9a 10 80 	movl   $0x80109ada,(%esp)
801023e6:	e8 69 e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801023eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801023ee:	66 85 c0             	test   %ax,%ax
801023f1:	75 02                	jne    801023f5 <dirlink+0x83>
      break;
801023f3:	eb 16                	jmp    8010240b <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801023f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f8:	83 c0 10             	add    $0x10,%eax
801023fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
80102404:	8b 40 58             	mov    0x58(%eax),%eax
80102407:	39 c2                	cmp    %eax,%edx
80102409:	72 ae                	jb     801023b9 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
8010240b:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102412:	00 
80102413:	8b 45 0c             	mov    0xc(%ebp),%eax
80102416:	89 44 24 04          	mov    %eax,0x4(%esp)
8010241a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010241d:	83 c0 02             	add    $0x2,%eax
80102420:	89 04 24             	mov    %eax,(%esp)
80102423:	e8 90 34 00 00       	call   801058b8 <strncpy>
  de.inum = inum;
80102428:	8b 45 10             	mov    0x10(%ebp),%eax
8010242b:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010242f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102432:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102439:	00 
8010243a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010243e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102441:	89 44 24 04          	mov    %eax,0x4(%esp)
80102445:	8b 45 08             	mov    0x8(%ebp),%eax
80102448:	89 04 24             	mov    %eax,(%esp)
8010244b:	e8 6d fc ff ff       	call   801020bd <writei>
80102450:	83 f8 10             	cmp    $0x10,%eax
80102453:	74 0c                	je     80102461 <dirlink+0xef>
    panic("dirlink");
80102455:	c7 04 24 e7 9a 10 80 	movl   $0x80109ae7,(%esp)
8010245c:	e8 f3 e0 ff ff       	call   80100554 <panic>

  return 0;
80102461:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102466:	c9                   	leave  
80102467:	c3                   	ret    

80102468 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102468:	55                   	push   %ebp
80102469:	89 e5                	mov    %esp,%ebp
8010246b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010246e:	eb 03                	jmp    80102473 <skipelem+0xb>
    path++;
80102470:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102473:	8b 45 08             	mov    0x8(%ebp),%eax
80102476:	8a 00                	mov    (%eax),%al
80102478:	3c 2f                	cmp    $0x2f,%al
8010247a:	74 f4                	je     80102470 <skipelem+0x8>
    path++;
  if(*path == 0)
8010247c:	8b 45 08             	mov    0x8(%ebp),%eax
8010247f:	8a 00                	mov    (%eax),%al
80102481:	84 c0                	test   %al,%al
80102483:	75 0a                	jne    8010248f <skipelem+0x27>
    return 0;
80102485:	b8 00 00 00 00       	mov    $0x0,%eax
8010248a:	e9 81 00 00 00       	jmp    80102510 <skipelem+0xa8>
  s = path;
8010248f:	8b 45 08             	mov    0x8(%ebp),%eax
80102492:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102495:	eb 03                	jmp    8010249a <skipelem+0x32>
    path++;
80102497:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010249a:	8b 45 08             	mov    0x8(%ebp),%eax
8010249d:	8a 00                	mov    (%eax),%al
8010249f:	3c 2f                	cmp    $0x2f,%al
801024a1:	74 09                	je     801024ac <skipelem+0x44>
801024a3:	8b 45 08             	mov    0x8(%ebp),%eax
801024a6:	8a 00                	mov    (%eax),%al
801024a8:	84 c0                	test   %al,%al
801024aa:	75 eb                	jne    80102497 <skipelem+0x2f>
    path++;
  len = path - s;
801024ac:	8b 55 08             	mov    0x8(%ebp),%edx
801024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b2:	29 c2                	sub    %eax,%edx
801024b4:	89 d0                	mov    %edx,%eax
801024b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801024b9:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801024bd:	7e 1c                	jle    801024db <skipelem+0x73>
    memmove(name, s, DIRSIZ);
801024bf:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024c6:	00 
801024c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801024ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801024d1:	89 04 24             	mov    %eax,(%esp)
801024d4:	e8 f2 32 00 00       	call   801057cb <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024d9:	eb 29                	jmp    80102504 <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
801024db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024de:	89 44 24 08          	mov    %eax,0x8(%esp)
801024e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801024e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801024ec:	89 04 24             	mov    %eax,(%esp)
801024ef:	e8 d7 32 00 00       	call   801057cb <memmove>
    name[len] = 0;
801024f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801024fa:	01 d0                	add    %edx,%eax
801024fc:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024ff:	eb 03                	jmp    80102504 <skipelem+0x9c>
    path++;
80102501:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102504:	8b 45 08             	mov    0x8(%ebp),%eax
80102507:	8a 00                	mov    (%eax),%al
80102509:	3c 2f                	cmp    $0x2f,%al
8010250b:	74 f4                	je     80102501 <skipelem+0x99>
    path++;
  return path;
8010250d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102510:	c9                   	leave  
80102511:	c3                   	ret    

80102512 <strcmp3>:

int
strcmp3(const char *p, const char *q)
{
80102512:	55                   	push   %ebp
80102513:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80102515:	eb 06                	jmp    8010251d <strcmp3+0xb>
    p++, q++;
80102517:	ff 45 08             	incl   0x8(%ebp)
8010251a:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp3(const char *p, const char *q)
{
  while(*p && *p == *q)
8010251d:	8b 45 08             	mov    0x8(%ebp),%eax
80102520:	8a 00                	mov    (%eax),%al
80102522:	84 c0                	test   %al,%al
80102524:	74 0e                	je     80102534 <strcmp3+0x22>
80102526:	8b 45 08             	mov    0x8(%ebp),%eax
80102529:	8a 10                	mov    (%eax),%dl
8010252b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010252e:	8a 00                	mov    (%eax),%al
80102530:	38 c2                	cmp    %al,%dl
80102532:	74 e3                	je     80102517 <strcmp3+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80102534:	8b 45 08             	mov    0x8(%ebp),%eax
80102537:	8a 00                	mov    (%eax),%al
80102539:	0f b6 d0             	movzbl %al,%edx
8010253c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010253f:	8a 00                	mov    (%eax),%al
80102541:	0f b6 c0             	movzbl %al,%eax
80102544:	29 c2                	sub    %eax,%edx
80102546:	89 d0                	mov    %edx,%eax
}
80102548:	5d                   	pop    %ebp
80102549:	c3                   	ret    

8010254a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010254a:	55                   	push   %ebp
8010254b:	89 e5                	mov    %esp,%ebp
8010254d:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102550:	8b 45 08             	mov    0x8(%ebp),%eax
80102553:	8a 00                	mov    (%eax),%al
80102555:	3c 2f                	cmp    $0x2f,%al
80102557:	75 19                	jne    80102572 <namex+0x28>
    ip = iget(ROOTDEV, ROOTINO);
80102559:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102560:	00 
80102561:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102568:	e8 4e f4 ff ff       	call   801019bb <iget>
8010256d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102570:	eb 13                	jmp    80102585 <namex+0x3b>
  else
    ip = idup(myproc()->cwd);
80102572:	e8 bc 1f 00 00       	call   80104533 <myproc>
80102577:	8b 40 68             	mov    0x68(%eax),%eax
8010257a:	89 04 24             	mov    %eax,(%esp)
8010257d:	e8 0e f5 ff ff       	call   80101a90 <idup>
80102582:	89 45 f4             	mov    %eax,-0xc(%ebp)

  struct proc* p = myproc();
80102585:	e8 a9 1f 00 00       	call   80104533 <myproc>
8010258a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct container* cont = NULL;
8010258d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(p != NULL){
80102594:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80102598:	74 0c                	je     801025a6 <namex+0x5c>
    cont = p->cont;
8010259a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010259d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801025a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  }

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
801025a6:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
801025ad:	00 
801025ae:	c7 44 24 04 ef 9a 10 	movl   $0x80109aef,0x4(%esp)
801025b5:	80 
801025b6:	8b 45 08             	mov    0x8(%ebp),%eax
801025b9:	89 04 24             	mov    %eax,(%esp)
801025bc:	e8 a9 32 00 00       	call   8010586a <strncmp>
801025c1:	85 c0                	test   %eax,%eax
801025c3:	75 21                	jne    801025e6 <namex+0x9c>
801025c5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801025c9:	74 1b                	je     801025e6 <namex+0x9c>
801025cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025ce:	8b 40 38             	mov    0x38(%eax),%eax
801025d1:	8b 50 04             	mov    0x4(%eax),%edx
801025d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025d7:	8b 40 04             	mov    0x4(%eax),%eax
801025da:	39 c2                	cmp    %eax,%edx
801025dc:	75 08                	jne    801025e6 <namex+0x9c>
    return ip;
801025de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025e1:	e9 45 01 00 00       	jmp    8010272b <namex+0x1e1>
  }
  
  while((path = skipelem(path, name)) != 0){
801025e6:	e9 06 01 00 00       	jmp    801026f1 <namex+0x1a7>
    ilock(ip);
801025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ee:	89 04 24             	mov    %eax,(%esp)
801025f1:	e8 cc f4 ff ff       	call   80101ac2 <ilock>

    if(ip->type != T_DIR){
801025f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f9:	8b 40 50             	mov    0x50(%eax),%eax
801025fc:	66 83 f8 01          	cmp    $0x1,%ax
80102600:	74 15                	je     80102617 <namex+0xcd>
      iunlockput(ip);
80102602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102605:	89 04 24             	mov    %eax,(%esp)
80102608:	e8 b4 f6 ff ff       	call   80101cc1 <iunlockput>
      return 0;
8010260d:	b8 00 00 00 00       	mov    $0x0,%eax
80102612:	e9 14 01 00 00       	jmp    8010272b <namex+0x1e1>
    }

    if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
80102617:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
8010261e:	00 
8010261f:	c7 44 24 04 ef 9a 10 	movl   $0x80109aef,0x4(%esp)
80102626:	80 
80102627:	8b 45 08             	mov    0x8(%ebp),%eax
8010262a:	89 04 24             	mov    %eax,(%esp)
8010262d:	e8 38 32 00 00       	call   8010586a <strncmp>
80102632:	85 c0                	test   %eax,%eax
80102634:	75 2c                	jne    80102662 <namex+0x118>
80102636:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010263a:	74 26                	je     80102662 <namex+0x118>
8010263c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010263f:	8b 40 38             	mov    0x38(%eax),%eax
80102642:	8b 50 04             	mov    0x4(%eax),%edx
80102645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102648:	8b 40 04             	mov    0x4(%eax),%eax
8010264b:	39 c2                	cmp    %eax,%edx
8010264d:	75 13                	jne    80102662 <namex+0x118>
      iunlock(ip);
8010264f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102652:	89 04 24             	mov    %eax,(%esp)
80102655:	e8 72 f5 ff ff       	call   80101bcc <iunlock>
      return ip;
8010265a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010265d:	e9 c9 00 00 00       	jmp    8010272b <namex+0x1e1>
    }

    if(cont != NULL && ip->inum == ROOTINO){
80102662:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102666:	74 21                	je     80102689 <namex+0x13f>
80102668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010266b:	8b 40 04             	mov    0x4(%eax),%eax
8010266e:	83 f8 01             	cmp    $0x1,%eax
80102671:	75 16                	jne    80102689 <namex+0x13f>
      iunlock(ip);
80102673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102676:	89 04 24             	mov    %eax,(%esp)
80102679:	e8 4e f5 ff ff       	call   80101bcc <iunlock>
      return cont->root;
8010267e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102681:	8b 40 38             	mov    0x38(%eax),%eax
80102684:	e9 a2 00 00 00       	jmp    8010272b <namex+0x1e1>
    }

    if(nameiparent && *path == '\0'){
80102689:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010268d:	74 1c                	je     801026ab <namex+0x161>
8010268f:	8b 45 08             	mov    0x8(%ebp),%eax
80102692:	8a 00                	mov    (%eax),%al
80102694:	84 c0                	test   %al,%al
80102696:	75 13                	jne    801026ab <namex+0x161>
      // Stop one level early.
      iunlock(ip);
80102698:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010269b:	89 04 24             	mov    %eax,(%esp)
8010269e:	e8 29 f5 ff ff       	call   80101bcc <iunlock>
      return ip;
801026a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a6:	e9 80 00 00 00       	jmp    8010272b <namex+0x1e1>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801026ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801026b2:	00 
801026b3:	8b 45 10             	mov    0x10(%ebp),%eax
801026b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801026ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026bd:	89 04 24             	mov    %eax,(%esp)
801026c0:	e8 e7 fb ff ff       	call   801022ac <dirlookup>
801026c5:	89 45 e8             	mov    %eax,-0x18(%ebp)
801026c8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801026cc:	75 12                	jne    801026e0 <namex+0x196>
      iunlockput(ip);
801026ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026d1:	89 04 24             	mov    %eax,(%esp)
801026d4:	e8 e8 f5 ff ff       	call   80101cc1 <iunlockput>
      return 0;
801026d9:	b8 00 00 00 00       	mov    $0x0,%eax
801026de:	eb 4b                	jmp    8010272b <namex+0x1e1>
    }
    iunlockput(ip);
801026e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e3:	89 04 24             	mov    %eax,(%esp)
801026e6:	e8 d6 f5 ff ff       	call   80101cc1 <iunlockput>

    ip = next;
801026eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801026ee:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
    return ip;
  }
  
  while((path = skipelem(path, name)) != 0){
801026f1:	8b 45 10             	mov    0x10(%ebp),%eax
801026f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801026f8:	8b 45 08             	mov    0x8(%ebp),%eax
801026fb:	89 04 24             	mov    %eax,(%esp)
801026fe:	e8 65 fd ff ff       	call   80102468 <skipelem>
80102703:	89 45 08             	mov    %eax,0x8(%ebp)
80102706:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010270a:	0f 85 db fe ff ff    	jne    801025eb <namex+0xa1>
    }
    iunlockput(ip);

    ip = next;
  }
  if(nameiparent){
80102710:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102714:	74 12                	je     80102728 <namex+0x1de>
    iput(ip);
80102716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102719:	89 04 24             	mov    %eax,(%esp)
8010271c:	e8 ef f4 ff ff       	call   80101c10 <iput>
    return 0;
80102721:	b8 00 00 00 00       	mov    $0x0,%eax
80102726:	eb 03                	jmp    8010272b <namex+0x1e1>
  }

  
  return ip;
80102728:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010272b:	c9                   	leave  
8010272c:	c3                   	ret    

8010272d <namei>:

struct inode*
namei(char *path)
{
8010272d:	55                   	push   %ebp
8010272e:	89 e5                	mov    %esp,%ebp
80102730:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102733:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102736:	89 44 24 08          	mov    %eax,0x8(%esp)
8010273a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102741:	00 
80102742:	8b 45 08             	mov    0x8(%ebp),%eax
80102745:	89 04 24             	mov    %eax,(%esp)
80102748:	e8 fd fd ff ff       	call   8010254a <namex>
}
8010274d:	c9                   	leave  
8010274e:	c3                   	ret    

8010274f <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010274f:	55                   	push   %ebp
80102750:	89 e5                	mov    %esp,%ebp
80102752:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102755:	8b 45 0c             	mov    0xc(%ebp),%eax
80102758:	89 44 24 08          	mov    %eax,0x8(%esp)
8010275c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102763:	00 
80102764:	8b 45 08             	mov    0x8(%ebp),%eax
80102767:	89 04 24             	mov    %eax,(%esp)
8010276a:	e8 db fd ff ff       	call   8010254a <namex>
}
8010276f:	c9                   	leave  
80102770:	c3                   	ret    
80102771:	00 00                	add    %al,(%eax)
	...

80102774 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102774:	55                   	push   %ebp
80102775:	89 e5                	mov    %esp,%ebp
80102777:	83 ec 14             	sub    $0x14,%esp
8010277a:	8b 45 08             	mov    0x8(%ebp),%eax
8010277d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102781:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102784:	89 c2                	mov    %eax,%edx
80102786:	ec                   	in     (%dx),%al
80102787:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010278a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
8010278d:	c9                   	leave  
8010278e:	c3                   	ret    

8010278f <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010278f:	55                   	push   %ebp
80102790:	89 e5                	mov    %esp,%ebp
80102792:	57                   	push   %edi
80102793:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102794:	8b 55 08             	mov    0x8(%ebp),%edx
80102797:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010279a:	8b 45 10             	mov    0x10(%ebp),%eax
8010279d:	89 cb                	mov    %ecx,%ebx
8010279f:	89 df                	mov    %ebx,%edi
801027a1:	89 c1                	mov    %eax,%ecx
801027a3:	fc                   	cld    
801027a4:	f3 6d                	rep insl (%dx),%es:(%edi)
801027a6:	89 c8                	mov    %ecx,%eax
801027a8:	89 fb                	mov    %edi,%ebx
801027aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027ad:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027b0:	5b                   	pop    %ebx
801027b1:	5f                   	pop    %edi
801027b2:	5d                   	pop    %ebp
801027b3:	c3                   	ret    

801027b4 <outb>:

static inline void
outb(ushort port, uchar data)
{
801027b4:	55                   	push   %ebp
801027b5:	89 e5                	mov    %esp,%ebp
801027b7:	83 ec 08             	sub    $0x8,%esp
801027ba:	8b 45 08             	mov    0x8(%ebp),%eax
801027bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801027c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801027c4:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801027c7:	8a 45 f8             	mov    -0x8(%ebp),%al
801027ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
801027cd:	ee                   	out    %al,(%dx)
}
801027ce:	c9                   	leave  
801027cf:	c3                   	ret    

801027d0 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801027d0:	55                   	push   %ebp
801027d1:	89 e5                	mov    %esp,%ebp
801027d3:	56                   	push   %esi
801027d4:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801027d5:	8b 55 08             	mov    0x8(%ebp),%edx
801027d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027db:	8b 45 10             	mov    0x10(%ebp),%eax
801027de:	89 cb                	mov    %ecx,%ebx
801027e0:	89 de                	mov    %ebx,%esi
801027e2:	89 c1                	mov    %eax,%ecx
801027e4:	fc                   	cld    
801027e5:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027e7:	89 c8                	mov    %ecx,%eax
801027e9:	89 f3                	mov    %esi,%ebx
801027eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027ee:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801027f1:	5b                   	pop    %ebx
801027f2:	5e                   	pop    %esi
801027f3:	5d                   	pop    %ebp
801027f4:	c3                   	ret    

801027f5 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801027fb:	90                   	nop
801027fc:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102803:	e8 6c ff ff ff       	call   80102774 <inb>
80102808:	0f b6 c0             	movzbl %al,%eax
8010280b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010280e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102811:	25 c0 00 00 00       	and    $0xc0,%eax
80102816:	83 f8 40             	cmp    $0x40,%eax
80102819:	75 e1                	jne    801027fc <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010281b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010281f:	74 11                	je     80102832 <idewait+0x3d>
80102821:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102824:	83 e0 21             	and    $0x21,%eax
80102827:	85 c0                	test   %eax,%eax
80102829:	74 07                	je     80102832 <idewait+0x3d>
    return -1;
8010282b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102830:	eb 05                	jmp    80102837 <idewait+0x42>
  return 0;
80102832:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102837:	c9                   	leave  
80102838:	c3                   	ret    

80102839 <ideinit>:

void
ideinit(void)
{
80102839:	55                   	push   %ebp
8010283a:	89 e5                	mov    %esp,%ebp
8010283c:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010283f:	c7 44 24 04 f2 9a 10 	movl   $0x80109af2,0x4(%esp)
80102846:	80 
80102847:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
8010284e:	e8 2b 2c 00 00       	call   8010547e <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102853:	a1 40 62 11 80       	mov    0x80116240,%eax
80102858:	48                   	dec    %eax
80102859:	89 44 24 04          	mov    %eax,0x4(%esp)
8010285d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102864:	e8 66 04 00 00       	call   80102ccf <ioapicenable>
  idewait(0);
80102869:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102870:	e8 80 ff ff ff       	call   801027f5 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102875:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010287c:	00 
8010287d:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102884:	e8 2b ff ff ff       	call   801027b4 <outb>
  for(i=0; i<1000; i++){
80102889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102890:	eb 1f                	jmp    801028b1 <ideinit+0x78>
    if(inb(0x1f7) != 0){
80102892:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102899:	e8 d6 fe ff ff       	call   80102774 <inb>
8010289e:	84 c0                	test   %al,%al
801028a0:	74 0c                	je     801028ae <ideinit+0x75>
      havedisk1 = 1;
801028a2:	c7 05 18 d9 10 80 01 	movl   $0x1,0x8010d918
801028a9:	00 00 00 
      break;
801028ac:	eb 0c                	jmp    801028ba <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801028ae:	ff 45 f4             	incl   -0xc(%ebp)
801028b1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801028b8:	7e d8                	jle    80102892 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801028ba:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801028c1:	00 
801028c2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028c9:	e8 e6 fe ff ff       	call   801027b4 <outb>
}
801028ce:	c9                   	leave  
801028cf:	c3                   	ret    

801028d0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028d0:	55                   	push   %ebp
801028d1:	89 e5                	mov    %esp,%ebp
801028d3:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801028d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028da:	75 0c                	jne    801028e8 <idestart+0x18>
    panic("idestart");
801028dc:	c7 04 24 f6 9a 10 80 	movl   $0x80109af6,(%esp)
801028e3:	e8 6c dc ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801028e8:	8b 45 08             	mov    0x8(%ebp),%eax
801028eb:	8b 40 08             	mov    0x8(%eax),%eax
801028ee:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
801028f3:	76 0c                	jbe    80102901 <idestart+0x31>
    panic("incorrect blockno");
801028f5:	c7 04 24 ff 9a 10 80 	movl   $0x80109aff,(%esp)
801028fc:	e8 53 dc ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102901:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102908:	8b 45 08             	mov    0x8(%ebp),%eax
8010290b:	8b 50 08             	mov    0x8(%eax),%edx
8010290e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102911:	0f af c2             	imul   %edx,%eax
80102914:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102917:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010291b:	75 07                	jne    80102924 <idestart+0x54>
8010291d:	b8 20 00 00 00       	mov    $0x20,%eax
80102922:	eb 05                	jmp    80102929 <idestart+0x59>
80102924:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102929:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010292c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102930:	75 07                	jne    80102939 <idestart+0x69>
80102932:	b8 30 00 00 00       	mov    $0x30,%eax
80102937:	eb 05                	jmp    8010293e <idestart+0x6e>
80102939:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010293e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102941:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102945:	7e 0c                	jle    80102953 <idestart+0x83>
80102947:	c7 04 24 f6 9a 10 80 	movl   $0x80109af6,(%esp)
8010294e:	e8 01 dc ff ff       	call   80100554 <panic>

  idewait(0);
80102953:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010295a:	e8 96 fe ff ff       	call   801027f5 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010295f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102966:	00 
80102967:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010296e:	e8 41 fe ff ff       	call   801027b4 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102976:	0f b6 c0             	movzbl %al,%eax
80102979:	89 44 24 04          	mov    %eax,0x4(%esp)
8010297d:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102984:	e8 2b fe ff ff       	call   801027b4 <outb>
  outb(0x1f3, sector & 0xff);
80102989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010298c:	0f b6 c0             	movzbl %al,%eax
8010298f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102993:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010299a:	e8 15 fe ff ff       	call   801027b4 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
8010299f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029a2:	c1 f8 08             	sar    $0x8,%eax
801029a5:	0f b6 c0             	movzbl %al,%eax
801029a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ac:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029b3:	e8 fc fd ff ff       	call   801027b4 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801029b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029bb:	c1 f8 10             	sar    $0x10,%eax
801029be:	0f b6 c0             	movzbl %al,%eax
801029c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029c5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029cc:	e8 e3 fd ff ff       	call   801027b4 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801029d1:	8b 45 08             	mov    0x8(%ebp),%eax
801029d4:	8b 40 04             	mov    0x4(%eax),%eax
801029d7:	83 e0 01             	and    $0x1,%eax
801029da:	c1 e0 04             	shl    $0x4,%eax
801029dd:	88 c2                	mov    %al,%dl
801029df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029e2:	c1 f8 18             	sar    $0x18,%eax
801029e5:	83 e0 0f             	and    $0xf,%eax
801029e8:	09 d0                	or     %edx,%eax
801029ea:	83 c8 e0             	or     $0xffffffe0,%eax
801029ed:	0f b6 c0             	movzbl %al,%eax
801029f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f4:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029fb:	e8 b4 fd ff ff       	call   801027b4 <outb>
  if(b->flags & B_DIRTY){
80102a00:	8b 45 08             	mov    0x8(%ebp),%eax
80102a03:	8b 00                	mov    (%eax),%eax
80102a05:	83 e0 04             	and    $0x4,%eax
80102a08:	85 c0                	test   %eax,%eax
80102a0a:	74 36                	je     80102a42 <idestart+0x172>
    outb(0x1f7, write_cmd);
80102a0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102a0f:	0f b6 c0             	movzbl %al,%eax
80102a12:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a16:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a1d:	e8 92 fd ff ff       	call   801027b4 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102a22:	8b 45 08             	mov    0x8(%ebp),%eax
80102a25:	83 c0 5c             	add    $0x5c,%eax
80102a28:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a2f:	00 
80102a30:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a34:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a3b:	e8 90 fd ff ff       	call   801027d0 <outsl>
80102a40:	eb 16                	jmp    80102a58 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102a42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a45:	0f b6 c0             	movzbl %al,%eax
80102a48:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a4c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a53:	e8 5c fd ff ff       	call   801027b4 <outb>
  }
}
80102a58:	c9                   	leave  
80102a59:	c3                   	ret    

80102a5a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a5a:	55                   	push   %ebp
80102a5b:	89 e5                	mov    %esp,%ebp
80102a5d:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a60:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102a67:	e8 33 2a 00 00       	call   8010549f <acquire>

  if((b = idequeue) == 0){
80102a6c:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a78:	75 11                	jne    80102a8b <ideintr+0x31>
    release(&idelock);
80102a7a:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102a81:	e8 83 2a 00 00       	call   80105509 <release>
    return;
80102a86:	e9 90 00 00 00       	jmp    80102b1b <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8e:	8b 40 58             	mov    0x58(%eax),%eax
80102a91:	a3 14 d9 10 80       	mov    %eax,0x8010d914

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a99:	8b 00                	mov    (%eax),%eax
80102a9b:	83 e0 04             	and    $0x4,%eax
80102a9e:	85 c0                	test   %eax,%eax
80102aa0:	75 2e                	jne    80102ad0 <ideintr+0x76>
80102aa2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102aa9:	e8 47 fd ff ff       	call   801027f5 <idewait>
80102aae:	85 c0                	test   %eax,%eax
80102ab0:	78 1e                	js     80102ad0 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab5:	83 c0 5c             	add    $0x5c,%eax
80102ab8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102abf:	00 
80102ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ac4:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102acb:	e8 bf fc ff ff       	call   8010278f <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad3:	8b 00                	mov    (%eax),%eax
80102ad5:	83 c8 02             	or     $0x2,%eax
80102ad8:	89 c2                	mov    %eax,%edx
80102ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102add:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae2:	8b 00                	mov    (%eax),%eax
80102ae4:	83 e0 fb             	and    $0xfffffffb,%eax
80102ae7:	89 c2                	mov    %eax,%edx
80102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aec:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af1:	89 04 24             	mov    %eax,(%esp)
80102af4:	e8 c2 23 00 00       	call   80104ebb <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102af9:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102afe:	85 c0                	test   %eax,%eax
80102b00:	74 0d                	je     80102b0f <ideintr+0xb5>
    idestart(idequeue);
80102b02:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102b07:	89 04 24             	mov    %eax,(%esp)
80102b0a:	e8 c1 fd ff ff       	call   801028d0 <idestart>

  release(&idelock);
80102b0f:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102b16:	e8 ee 29 00 00       	call   80105509 <release>
}
80102b1b:	c9                   	leave  
80102b1c:	c3                   	ret    

80102b1d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b1d:	55                   	push   %ebp
80102b1e:	89 e5                	mov    %esp,%ebp
80102b20:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102b23:	8b 45 08             	mov    0x8(%ebp),%eax
80102b26:	83 c0 0c             	add    $0xc,%eax
80102b29:	89 04 24             	mov    %eax,(%esp)
80102b2c:	e8 e6 28 00 00       	call   80105417 <holdingsleep>
80102b31:	85 c0                	test   %eax,%eax
80102b33:	75 0c                	jne    80102b41 <iderw+0x24>
    panic("iderw: buf not locked");
80102b35:	c7 04 24 11 9b 10 80 	movl   $0x80109b11,(%esp)
80102b3c:	e8 13 da ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b41:	8b 45 08             	mov    0x8(%ebp),%eax
80102b44:	8b 00                	mov    (%eax),%eax
80102b46:	83 e0 06             	and    $0x6,%eax
80102b49:	83 f8 02             	cmp    $0x2,%eax
80102b4c:	75 0c                	jne    80102b5a <iderw+0x3d>
    panic("iderw: nothing to do");
80102b4e:	c7 04 24 27 9b 10 80 	movl   $0x80109b27,(%esp)
80102b55:	e8 fa d9 ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5d:	8b 40 04             	mov    0x4(%eax),%eax
80102b60:	85 c0                	test   %eax,%eax
80102b62:	74 15                	je     80102b79 <iderw+0x5c>
80102b64:	a1 18 d9 10 80       	mov    0x8010d918,%eax
80102b69:	85 c0                	test   %eax,%eax
80102b6b:	75 0c                	jne    80102b79 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102b6d:	c7 04 24 3c 9b 10 80 	movl   $0x80109b3c,(%esp)
80102b74:	e8 db d9 ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b79:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102b80:	e8 1a 29 00 00       	call   8010549f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b85:	8b 45 08             	mov    0x8(%ebp),%eax
80102b88:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b8f:	c7 45 f4 14 d9 10 80 	movl   $0x8010d914,-0xc(%ebp)
80102b96:	eb 0b                	jmp    80102ba3 <iderw+0x86>
80102b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9b:	8b 00                	mov    (%eax),%eax
80102b9d:	83 c0 58             	add    $0x58,%eax
80102ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba6:	8b 00                	mov    (%eax),%eax
80102ba8:	85 c0                	test   %eax,%eax
80102baa:	75 ec                	jne    80102b98 <iderw+0x7b>
    ;
  *pp = b;
80102bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102baf:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102bb4:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102bb9:	3b 45 08             	cmp    0x8(%ebp),%eax
80102bbc:	75 0d                	jne    80102bcb <iderw+0xae>
    idestart(b);
80102bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc1:	89 04 24             	mov    %eax,(%esp)
80102bc4:	e8 07 fd ff ff       	call   801028d0 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc9:	eb 15                	jmp    80102be0 <iderw+0xc3>
80102bcb:	eb 13                	jmp    80102be0 <iderw+0xc3>
    sleep(b, &idelock);
80102bcd:	c7 44 24 04 e0 d8 10 	movl   $0x8010d8e0,0x4(%esp)
80102bd4:	80 
80102bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd8:	89 04 24             	mov    %eax,(%esp)
80102bdb:	e8 04 22 00 00       	call   80104de4 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102be0:	8b 45 08             	mov    0x8(%ebp),%eax
80102be3:	8b 00                	mov    (%eax),%eax
80102be5:	83 e0 06             	and    $0x6,%eax
80102be8:	83 f8 02             	cmp    $0x2,%eax
80102beb:	75 e0                	jne    80102bcd <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102bed:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102bf4:	e8 10 29 00 00       	call   80105509 <release>
}
80102bf9:	c9                   	leave  
80102bfa:	c3                   	ret    
	...

80102bfc <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bfc:	55                   	push   %ebp
80102bfd:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bff:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c04:	8b 55 08             	mov    0x8(%ebp),%edx
80102c07:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c09:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c0e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c11:	5d                   	pop    %ebp
80102c12:	c3                   	ret    

80102c13 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c13:	55                   	push   %ebp
80102c14:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c16:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c1b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c1e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c20:	a1 54 5b 11 80       	mov    0x80115b54,%eax
80102c25:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c28:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c2b:	5d                   	pop    %ebp
80102c2c:	c3                   	ret    

80102c2d <ioapicinit>:

void
ioapicinit(void)
{
80102c2d:	55                   	push   %ebp
80102c2e:	89 e5                	mov    %esp,%ebp
80102c30:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c33:	c7 05 54 5b 11 80 00 	movl   $0xfec00000,0x80115b54
80102c3a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c44:	e8 b3 ff ff ff       	call   80102bfc <ioapicread>
80102c49:	c1 e8 10             	shr    $0x10,%eax
80102c4c:	25 ff 00 00 00       	and    $0xff,%eax
80102c51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c5b:	e8 9c ff ff ff       	call   80102bfc <ioapicread>
80102c60:	c1 e8 18             	shr    $0x18,%eax
80102c63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c66:	a0 a0 5c 11 80       	mov    0x80115ca0,%al
80102c6b:	0f b6 c0             	movzbl %al,%eax
80102c6e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c71:	74 0c                	je     80102c7f <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c73:	c7 04 24 5c 9b 10 80 	movl   $0x80109b5c,(%esp)
80102c7a:	e8 42 d7 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c86:	eb 3d                	jmp    80102cc5 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c8b:	83 c0 20             	add    $0x20,%eax
80102c8e:	0d 00 00 01 00       	or     $0x10000,%eax
80102c93:	89 c2                	mov    %eax,%edx
80102c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c98:	83 c0 08             	add    $0x8,%eax
80102c9b:	01 c0                	add    %eax,%eax
80102c9d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102ca1:	89 04 24             	mov    %eax,(%esp)
80102ca4:	e8 6a ff ff ff       	call   80102c13 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cac:	83 c0 08             	add    $0x8,%eax
80102caf:	01 c0                	add    %eax,%eax
80102cb1:	40                   	inc    %eax
80102cb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cb9:	00 
80102cba:	89 04 24             	mov    %eax,(%esp)
80102cbd:	e8 51 ff ff ff       	call   80102c13 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cc2:	ff 45 f4             	incl   -0xc(%ebp)
80102cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ccb:	7e bb                	jle    80102c88 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ccd:	c9                   	leave  
80102cce:	c3                   	ret    

80102ccf <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ccf:	55                   	push   %ebp
80102cd0:	89 e5                	mov    %esp,%ebp
80102cd2:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd8:	83 c0 20             	add    $0x20,%eax
80102cdb:	89 c2                	mov    %eax,%edx
80102cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce0:	83 c0 08             	add    $0x8,%eax
80102ce3:	01 c0                	add    %eax,%eax
80102ce5:	89 54 24 04          	mov    %edx,0x4(%esp)
80102ce9:	89 04 24             	mov    %eax,(%esp)
80102cec:	e8 22 ff ff ff       	call   80102c13 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cf4:	c1 e0 18             	shl    $0x18,%eax
80102cf7:	8b 55 08             	mov    0x8(%ebp),%edx
80102cfa:	83 c2 08             	add    $0x8,%edx
80102cfd:	01 d2                	add    %edx,%edx
80102cff:	42                   	inc    %edx
80102d00:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d04:	89 14 24             	mov    %edx,(%esp)
80102d07:	e8 07 ff ff ff       	call   80102c13 <ioapicwrite>
}
80102d0c:	c9                   	leave  
80102d0d:	c3                   	ret    
	...

80102d10 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d10:	55                   	push   %ebp
80102d11:	89 e5                	mov    %esp,%ebp
80102d13:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d16:	c7 44 24 04 8e 9b 10 	movl   $0x80109b8e,0x4(%esp)
80102d1d:	80 
80102d1e:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102d25:	e8 54 27 00 00       	call   8010547e <initlock>
  kmem.use_lock = 0;
80102d2a:	c7 05 94 5b 11 80 00 	movl   $0x0,0x80115b94
80102d31:	00 00 00 
  freerange(vstart, vend);
80102d34:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d37:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3e:	89 04 24             	mov    %eax,(%esp)
80102d41:	e8 30 00 00 00       	call   80102d76 <freerange>
}
80102d46:	c9                   	leave  
80102d47:	c3                   	ret    

80102d48 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d48:	55                   	push   %ebp
80102d49:	89 e5                	mov    %esp,%ebp
80102d4b:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d51:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d55:	8b 45 08             	mov    0x8(%ebp),%eax
80102d58:	89 04 24             	mov    %eax,(%esp)
80102d5b:	e8 16 00 00 00       	call   80102d76 <freerange>
  kmem.use_lock = 1;
80102d60:	c7 05 94 5b 11 80 01 	movl   $0x1,0x80115b94
80102d67:	00 00 00 
  kmem.i = 0;
80102d6a:	c7 05 9c 5b 11 80 00 	movl   $0x0,0x80115b9c
80102d71:	00 00 00 
}
80102d74:	c9                   	leave  
80102d75:	c3                   	ret    

80102d76 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d76:	55                   	push   %ebp
80102d77:	89 e5                	mov    %esp,%ebp
80102d79:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d7c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d7f:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d84:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d89:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d8c:	eb 12                	jmp    80102da0 <freerange+0x2a>
    kfree(p);
80102d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d91:	89 04 24             	mov    %eax,(%esp)
80102d94:	e8 16 00 00 00       	call   80102daf <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d99:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102da3:	05 00 10 00 00       	add    $0x1000,%eax
80102da8:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102dab:	76 e1                	jbe    80102d8e <freerange+0x18>
    kfree(p);
}
80102dad:	c9                   	leave  
80102dae:	c3                   	ret    

80102daf <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102daf:	55                   	push   %ebp
80102db0:	89 e5                	mov    %esp,%ebp
80102db2:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102db5:	8b 45 08             	mov    0x8(%ebp),%eax
80102db8:	25 ff 0f 00 00       	and    $0xfff,%eax
80102dbd:	85 c0                	test   %eax,%eax
80102dbf:	75 18                	jne    80102dd9 <kfree+0x2a>
80102dc1:	81 7d 08 f0 8c 11 80 	cmpl   $0x80118cf0,0x8(%ebp)
80102dc8:	72 0f                	jb     80102dd9 <kfree+0x2a>
80102dca:	8b 45 08             	mov    0x8(%ebp),%eax
80102dcd:	05 00 00 00 80       	add    $0x80000000,%eax
80102dd2:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102dd7:	76 0c                	jbe    80102de5 <kfree+0x36>
    panic("kfree");
80102dd9:	c7 04 24 93 9b 10 80 	movl   $0x80109b93,(%esp)
80102de0:	e8 6f d7 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102de5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102dec:	00 
80102ded:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102df4:	00 
80102df5:	8b 45 08             	mov    0x8(%ebp),%eax
80102df8:	89 04 24             	mov    %eax,(%esp)
80102dfb:	e8 02 29 00 00       	call   80105702 <memset>

  if(kmem.use_lock){
80102e00:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102e05:	85 c0                	test   %eax,%eax
80102e07:	74 48                	je     80102e51 <kfree+0xa2>
    acquire(&kmem.lock);
80102e09:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102e10:	e8 8a 26 00 00       	call   8010549f <acquire>
    if(ticks > 1){
80102e15:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80102e1a:	83 f8 01             	cmp    $0x1,%eax
80102e1d:	76 32                	jbe    80102e51 <kfree+0xa2>
      int x = find(myproc()->cont->name);
80102e1f:	e8 0f 17 00 00       	call   80104533 <myproc>
80102e24:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102e2a:	83 c0 18             	add    $0x18,%eax
80102e2d:	89 04 24             	mov    %eax,(%esp)
80102e30:	e8 ae 63 00 00       	call   801091e3 <find>
80102e35:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102e38:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e3c:	78 13                	js     80102e51 <kfree+0xa2>
        reduce_curr_mem(1, x);
80102e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e41:	89 44 24 04          	mov    %eax,0x4(%esp)
80102e45:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102e4c:	e8 e5 66 00 00       	call   80109536 <reduce_curr_mem>
      }
    }
  }
  r = (struct run*)v;
80102e51:	8b 45 08             	mov    0x8(%ebp),%eax
80102e54:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102e57:	8b 15 98 5b 11 80    	mov    0x80115b98,%edx
80102e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e60:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102e65:	a3 98 5b 11 80       	mov    %eax,0x80115b98
  kmem.i--;
80102e6a:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
80102e6f:	48                   	dec    %eax
80102e70:	a3 9c 5b 11 80       	mov    %eax,0x80115b9c
  if(kmem.use_lock)
80102e75:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102e7a:	85 c0                	test   %eax,%eax
80102e7c:	74 0c                	je     80102e8a <kfree+0xdb>
    release(&kmem.lock);
80102e7e:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102e85:	e8 7f 26 00 00       	call   80105509 <release>
}
80102e8a:	c9                   	leave  
80102e8b:	c3                   	ret    

80102e8c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e8c:	55                   	push   %ebp
80102e8d:	89 e5                	mov    %esp,%ebp
80102e8f:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102e92:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102e97:	85 c0                	test   %eax,%eax
80102e99:	74 0c                	je     80102ea7 <kalloc+0x1b>
    acquire(&kmem.lock);
80102e9b:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102ea2:	e8 f8 25 00 00       	call   8010549f <acquire>
  }
  r = kmem.freelist;
80102ea7:	a1 98 5b 11 80       	mov    0x80115b98,%eax
80102eac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102eaf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102eb3:	74 0a                	je     80102ebf <kalloc+0x33>
    kmem.freelist = r->next;
80102eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102eb8:	8b 00                	mov    (%eax),%eax
80102eba:	a3 98 5b 11 80       	mov    %eax,0x80115b98
  kmem.i++;
80102ebf:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
80102ec4:	40                   	inc    %eax
80102ec5:	a3 9c 5b 11 80       	mov    %eax,0x80115b9c
  if((char*)r != 0){
80102eca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ece:	74 72                	je     80102f42 <kalloc+0xb6>
    if(ticks > 0){
80102ed0:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80102ed5:	85 c0                	test   %eax,%eax
80102ed7:	74 69                	je     80102f42 <kalloc+0xb6>
      int x = find(myproc()->cont->name);
80102ed9:	e8 55 16 00 00       	call   80104533 <myproc>
80102ede:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102ee4:	83 c0 18             	add    $0x18,%eax
80102ee7:	89 04 24             	mov    %eax,(%esp)
80102eea:	e8 f4 62 00 00       	call   801091e3 <find>
80102eef:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102ef2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102ef6:	78 4a                	js     80102f42 <kalloc+0xb6>
        int before = get_curr_mem(x);
80102ef8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102efb:	89 04 24             	mov    %eax,(%esp)
80102efe:	e8 78 64 00 00       	call   8010937b <get_curr_mem>
80102f03:	89 45 ec             	mov    %eax,-0x14(%ebp)
        set_curr_mem(1, x);
80102f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f09:	89 44 24 04          	mov    %eax,0x4(%esp)
80102f0d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102f14:	e8 8a 65 00 00       	call   801094a3 <set_curr_mem>
        int after = get_curr_mem(x);
80102f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f1c:	89 04 24             	mov    %eax,(%esp)
80102f1f:	e8 57 64 00 00       	call   8010937b <get_curr_mem>
80102f24:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(before == after){
80102f27:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f2a:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80102f2d:	75 13                	jne    80102f42 <kalloc+0xb6>
          cstop_container_helper(myproc()->cont);
80102f2f:	e8 ff 15 00 00       	call   80104533 <myproc>
80102f34:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102f3a:	89 04 24             	mov    %eax,(%esp)
80102f3d:	e8 5e 21 00 00       	call   801050a0 <cstop_container_helper>
        }
      }
   }
  }
  if(kmem.use_lock)
80102f42:	a1 94 5b 11 80       	mov    0x80115b94,%eax
80102f47:	85 c0                	test   %eax,%eax
80102f49:	74 0c                	je     80102f57 <kalloc+0xcb>
    release(&kmem.lock);
80102f4b:	c7 04 24 60 5b 11 80 	movl   $0x80115b60,(%esp)
80102f52:	e8 b2 25 00 00       	call   80105509 <release>
  return (char*)r;
80102f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102f5a:	c9                   	leave  
80102f5b:	c3                   	ret    

80102f5c <mem_usage>:

int mem_usage(void){
80102f5c:	55                   	push   %ebp
80102f5d:	89 e5                	mov    %esp,%ebp
  return kmem.i;
80102f5f:	a1 9c 5b 11 80       	mov    0x80115b9c,%eax
}
80102f64:	5d                   	pop    %ebp
80102f65:	c3                   	ret    

80102f66 <mem_avail>:

int mem_avail(void){
80102f66:	55                   	push   %ebp
80102f67:	89 e5                	mov    %esp,%ebp
80102f69:	83 ec 10             	sub    $0x10,%esp
  int freebytes = ((P2V(4*1024*1024) - (void*)end) + (P2V(PHYSTOP) - P2V(4*1024*1024)))/4096;
80102f6c:	b8 f0 8c 11 80       	mov    $0x80118cf0,%eax
80102f71:	ba 00 00 00 8e       	mov    $0x8e000000,%edx
80102f76:	29 c2                	sub    %eax,%edx
80102f78:	89 d0                	mov    %edx,%eax
80102f7a:	85 c0                	test   %eax,%eax
80102f7c:	79 05                	jns    80102f83 <mem_avail+0x1d>
80102f7e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102f83:	c1 f8 0c             	sar    $0xc,%eax
80102f86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return freebytes;
80102f89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102f8c:	c9                   	leave  
80102f8d:	c3                   	ret    
	...

80102f90 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102f90:	55                   	push   %ebp
80102f91:	89 e5                	mov    %esp,%ebp
80102f93:	83 ec 14             	sub    $0x14,%esp
80102f96:	8b 45 08             	mov    0x8(%ebp),%eax
80102f99:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fa0:	89 c2                	mov    %eax,%edx
80102fa2:	ec                   	in     (%dx),%al
80102fa3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102fa6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102fa9:	c9                   	leave  
80102faa:	c3                   	ret    

80102fab <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102fab:	55                   	push   %ebp
80102fac:	89 e5                	mov    %esp,%ebp
80102fae:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102fb1:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102fb8:	e8 d3 ff ff ff       	call   80102f90 <inb>
80102fbd:	0f b6 c0             	movzbl %al,%eax
80102fc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fc6:	83 e0 01             	and    $0x1,%eax
80102fc9:	85 c0                	test   %eax,%eax
80102fcb:	75 0a                	jne    80102fd7 <kbdgetc+0x2c>
    return -1;
80102fcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fd2:	e9 21 01 00 00       	jmp    801030f8 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102fd7:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102fde:	e8 ad ff ff ff       	call   80102f90 <inb>
80102fe3:	0f b6 c0             	movzbl %al,%eax
80102fe6:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102fe9:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ff0:	75 17                	jne    80103009 <kbdgetc+0x5e>
    shift |= E0ESC;
80102ff2:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80102ff7:	83 c8 40             	or     $0x40,%eax
80102ffa:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
    return 0;
80102fff:	b8 00 00 00 00       	mov    $0x0,%eax
80103004:	e9 ef 00 00 00       	jmp    801030f8 <kbdgetc+0x14d>
  } else if(data & 0x80){
80103009:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010300c:	25 80 00 00 00       	and    $0x80,%eax
80103011:	85 c0                	test   %eax,%eax
80103013:	74 44                	je     80103059 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80103015:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
8010301a:	83 e0 40             	and    $0x40,%eax
8010301d:	85 c0                	test   %eax,%eax
8010301f:	75 08                	jne    80103029 <kbdgetc+0x7e>
80103021:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103024:	83 e0 7f             	and    $0x7f,%eax
80103027:	eb 03                	jmp    8010302c <kbdgetc+0x81>
80103029:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010302c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010302f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103032:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103037:	8a 00                	mov    (%eax),%al
80103039:	83 c8 40             	or     $0x40,%eax
8010303c:	0f b6 c0             	movzbl %al,%eax
8010303f:	f7 d0                	not    %eax
80103041:	89 c2                	mov    %eax,%edx
80103043:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103048:	21 d0                	and    %edx,%eax
8010304a:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
    return 0;
8010304f:	b8 00 00 00 00       	mov    $0x0,%eax
80103054:	e9 9f 00 00 00       	jmp    801030f8 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103059:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
8010305e:	83 e0 40             	and    $0x40,%eax
80103061:	85 c0                	test   %eax,%eax
80103063:	74 14                	je     80103079 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103065:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010306c:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103071:	83 e0 bf             	and    $0xffffffbf,%eax
80103074:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  }

  shift |= shiftcode[data];
80103079:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010307c:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103081:	8a 00                	mov    (%eax),%al
80103083:	0f b6 d0             	movzbl %al,%edx
80103086:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
8010308b:	09 d0                	or     %edx,%eax
8010308d:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  shift ^= togglecode[data];
80103092:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103095:	05 20 b1 10 80       	add    $0x8010b120,%eax
8010309a:	8a 00                	mov    (%eax),%al
8010309c:	0f b6 d0             	movzbl %al,%edx
8010309f:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030a4:	31 d0                	xor    %edx,%eax
801030a6:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  c = charcode[shift & (CTL | SHIFT)][data];
801030ab:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030b0:	83 e0 03             	and    $0x3,%eax
801030b3:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
801030ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030bd:	01 d0                	add    %edx,%eax
801030bf:	8a 00                	mov    (%eax),%al
801030c1:	0f b6 c0             	movzbl %al,%eax
801030c4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801030c7:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030cc:	83 e0 08             	and    $0x8,%eax
801030cf:	85 c0                	test   %eax,%eax
801030d1:	74 22                	je     801030f5 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
801030d3:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801030d7:	76 0c                	jbe    801030e5 <kbdgetc+0x13a>
801030d9:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801030dd:	77 06                	ja     801030e5 <kbdgetc+0x13a>
      c += 'A' - 'a';
801030df:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801030e3:	eb 10                	jmp    801030f5 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801030e5:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801030e9:	76 0a                	jbe    801030f5 <kbdgetc+0x14a>
801030eb:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801030ef:	77 04                	ja     801030f5 <kbdgetc+0x14a>
      c += 'a' - 'A';
801030f1:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801030f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801030f8:	c9                   	leave  
801030f9:	c3                   	ret    

801030fa <kbdintr>:

void
kbdintr(void)
{
801030fa:	55                   	push   %ebp
801030fb:	89 e5                	mov    %esp,%ebp
801030fd:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80103100:	c7 04 24 ab 2f 10 80 	movl   $0x80102fab,(%esp)
80103107:	e8 e9 d6 ff ff       	call   801007f5 <consoleintr>
}
8010310c:	c9                   	leave  
8010310d:	c3                   	ret    
	...

80103110 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103110:	55                   	push   %ebp
80103111:	89 e5                	mov    %esp,%ebp
80103113:	83 ec 14             	sub    $0x14,%esp
80103116:	8b 45 08             	mov    0x8(%ebp),%eax
80103119:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010311d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103120:	89 c2                	mov    %eax,%edx
80103122:	ec                   	in     (%dx),%al
80103123:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103126:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103129:	c9                   	leave  
8010312a:	c3                   	ret    

8010312b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010312b:	55                   	push   %ebp
8010312c:	89 e5                	mov    %esp,%ebp
8010312e:	83 ec 08             	sub    $0x8,%esp
80103131:	8b 45 08             	mov    0x8(%ebp),%eax
80103134:	8b 55 0c             	mov    0xc(%ebp),%edx
80103137:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010313b:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010313e:	8a 45 f8             	mov    -0x8(%ebp),%al
80103141:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103144:	ee                   	out    %al,(%dx)
}
80103145:	c9                   	leave  
80103146:	c3                   	ret    

80103147 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103147:	55                   	push   %ebp
80103148:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010314a:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
8010314f:	8b 55 08             	mov    0x8(%ebp),%edx
80103152:	c1 e2 02             	shl    $0x2,%edx
80103155:	01 c2                	add    %eax,%edx
80103157:	8b 45 0c             	mov    0xc(%ebp),%eax
8010315a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010315c:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
80103161:	83 c0 20             	add    $0x20,%eax
80103164:	8b 00                	mov    (%eax),%eax
}
80103166:	5d                   	pop    %ebp
80103167:	c3                   	ret    

80103168 <lapicinit>:

void
lapicinit(void)
{
80103168:	55                   	push   %ebp
80103169:	89 e5                	mov    %esp,%ebp
8010316b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
8010316e:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
80103173:	85 c0                	test   %eax,%eax
80103175:	75 05                	jne    8010317c <lapicinit+0x14>
    return;
80103177:	e9 43 01 00 00       	jmp    801032bf <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010317c:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80103183:	00 
80103184:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
8010318b:	e8 b7 ff ff ff       	call   80103147 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103190:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80103197:	00 
80103198:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
8010319f:	e8 a3 ff ff ff       	call   80103147 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801031a4:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801031ab:	00 
801031ac:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031b3:	e8 8f ff ff ff       	call   80103147 <lapicw>
  lapicw(TICR, 10000000);
801031b8:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801031bf:	00 
801031c0:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801031c7:	e8 7b ff ff ff       	call   80103147 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801031cc:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801031d3:	00 
801031d4:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801031db:	e8 67 ff ff ff       	call   80103147 <lapicw>
  lapicw(LINT1, MASKED);
801031e0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801031e7:	00 
801031e8:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801031ef:	e8 53 ff ff ff       	call   80103147 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801031f4:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
801031f9:	83 c0 30             	add    $0x30,%eax
801031fc:	8b 00                	mov    (%eax),%eax
801031fe:	c1 e8 10             	shr    $0x10,%eax
80103201:	0f b6 c0             	movzbl %al,%eax
80103204:	83 f8 03             	cmp    $0x3,%eax
80103207:	76 14                	jbe    8010321d <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80103209:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103210:	00 
80103211:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103218:	e8 2a ff ff ff       	call   80103147 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010321d:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103224:	00 
80103225:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
8010322c:	e8 16 ff ff ff       	call   80103147 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103231:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103238:	00 
80103239:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103240:	e8 02 ff ff ff       	call   80103147 <lapicw>
  lapicw(ESR, 0);
80103245:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010324c:	00 
8010324d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103254:	e8 ee fe ff ff       	call   80103147 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103259:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103260:	00 
80103261:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103268:	e8 da fe ff ff       	call   80103147 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010326d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103274:	00 
80103275:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010327c:	e8 c6 fe ff ff       	call   80103147 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103281:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103288:	00 
80103289:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103290:	e8 b2 fe ff ff       	call   80103147 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103295:	90                   	nop
80103296:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
8010329b:	05 00 03 00 00       	add    $0x300,%eax
801032a0:	8b 00                	mov    (%eax),%eax
801032a2:	25 00 10 00 00       	and    $0x1000,%eax
801032a7:	85 c0                	test   %eax,%eax
801032a9:	75 eb                	jne    80103296 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801032ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801032b2:	00 
801032b3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801032ba:	e8 88 fe ff ff       	call   80103147 <lapicw>
}
801032bf:	c9                   	leave  
801032c0:	c3                   	ret    

801032c1 <lapicid>:

int
lapicid(void)
{
801032c1:	55                   	push   %ebp
801032c2:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801032c4:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
801032c9:	85 c0                	test   %eax,%eax
801032cb:	75 07                	jne    801032d4 <lapicid+0x13>
    return 0;
801032cd:	b8 00 00 00 00       	mov    $0x0,%eax
801032d2:	eb 0d                	jmp    801032e1 <lapicid+0x20>
  return lapic[ID] >> 24;
801032d4:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
801032d9:	83 c0 20             	add    $0x20,%eax
801032dc:	8b 00                	mov    (%eax),%eax
801032de:	c1 e8 18             	shr    $0x18,%eax
}
801032e1:	5d                   	pop    %ebp
801032e2:	c3                   	ret    

801032e3 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801032e3:	55                   	push   %ebp
801032e4:	89 e5                	mov    %esp,%ebp
801032e6:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801032e9:	a1 a0 5b 11 80       	mov    0x80115ba0,%eax
801032ee:	85 c0                	test   %eax,%eax
801032f0:	74 14                	je     80103306 <lapiceoi+0x23>
    lapicw(EOI, 0);
801032f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801032f9:	00 
801032fa:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103301:	e8 41 fe ff ff       	call   80103147 <lapicw>
}
80103306:	c9                   	leave  
80103307:	c3                   	ret    

80103308 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103308:	55                   	push   %ebp
80103309:	89 e5                	mov    %esp,%ebp
}
8010330b:	5d                   	pop    %ebp
8010330c:	c3                   	ret    

8010330d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010330d:	55                   	push   %ebp
8010330e:	89 e5                	mov    %esp,%ebp
80103310:	83 ec 1c             	sub    $0x1c,%esp
80103313:	8b 45 08             	mov    0x8(%ebp),%eax
80103316:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103319:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103320:	00 
80103321:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103328:	e8 fe fd ff ff       	call   8010312b <outb>
  outb(CMOS_PORT+1, 0x0A);
8010332d:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103334:	00 
80103335:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010333c:	e8 ea fd ff ff       	call   8010312b <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103341:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103348:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010334b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103350:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103353:	8d 50 02             	lea    0x2(%eax),%edx
80103356:	8b 45 0c             	mov    0xc(%ebp),%eax
80103359:	c1 e8 04             	shr    $0x4,%eax
8010335c:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010335f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103363:	c1 e0 18             	shl    $0x18,%eax
80103366:	89 44 24 04          	mov    %eax,0x4(%esp)
8010336a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103371:	e8 d1 fd ff ff       	call   80103147 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103376:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
8010337d:	00 
8010337e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103385:	e8 bd fd ff ff       	call   80103147 <lapicw>
  microdelay(200);
8010338a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103391:	e8 72 ff ff ff       	call   80103308 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103396:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010339d:	00 
8010339e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801033a5:	e8 9d fd ff ff       	call   80103147 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801033aa:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801033b1:	e8 52 ff ff ff       	call   80103308 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801033b6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801033bd:	eb 3f                	jmp    801033fe <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
801033bf:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801033c3:	c1 e0 18             	shl    $0x18,%eax
801033c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801033ca:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801033d1:	e8 71 fd ff ff       	call   80103147 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801033d6:	8b 45 0c             	mov    0xc(%ebp),%eax
801033d9:	c1 e8 0c             	shr    $0xc,%eax
801033dc:	80 cc 06             	or     $0x6,%ah
801033df:	89 44 24 04          	mov    %eax,0x4(%esp)
801033e3:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801033ea:	e8 58 fd ff ff       	call   80103147 <lapicw>
    microdelay(200);
801033ef:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801033f6:	e8 0d ff ff ff       	call   80103308 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801033fb:	ff 45 fc             	incl   -0x4(%ebp)
801033fe:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103402:	7e bb                	jle    801033bf <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103404:	c9                   	leave  
80103405:	c3                   	ret    

80103406 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103406:	55                   	push   %ebp
80103407:	89 e5                	mov    %esp,%ebp
80103409:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
8010340c:	8b 45 08             	mov    0x8(%ebp),%eax
8010340f:	0f b6 c0             	movzbl %al,%eax
80103412:	89 44 24 04          	mov    %eax,0x4(%esp)
80103416:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010341d:	e8 09 fd ff ff       	call   8010312b <outb>
  microdelay(200);
80103422:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103429:	e8 da fe ff ff       	call   80103308 <microdelay>

  return inb(CMOS_RETURN);
8010342e:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103435:	e8 d6 fc ff ff       	call   80103110 <inb>
8010343a:	0f b6 c0             	movzbl %al,%eax
}
8010343d:	c9                   	leave  
8010343e:	c3                   	ret    

8010343f <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010343f:	55                   	push   %ebp
80103440:	89 e5                	mov    %esp,%ebp
80103442:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103445:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010344c:	e8 b5 ff ff ff       	call   80103406 <cmos_read>
80103451:	8b 55 08             	mov    0x8(%ebp),%edx
80103454:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103456:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010345d:	e8 a4 ff ff ff       	call   80103406 <cmos_read>
80103462:	8b 55 08             	mov    0x8(%ebp),%edx
80103465:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103468:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010346f:	e8 92 ff ff ff       	call   80103406 <cmos_read>
80103474:	8b 55 08             	mov    0x8(%ebp),%edx
80103477:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010347a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103481:	e8 80 ff ff ff       	call   80103406 <cmos_read>
80103486:	8b 55 08             	mov    0x8(%ebp),%edx
80103489:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010348c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103493:	e8 6e ff ff ff       	call   80103406 <cmos_read>
80103498:	8b 55 08             	mov    0x8(%ebp),%edx
8010349b:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010349e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801034a5:	e8 5c ff ff ff       	call   80103406 <cmos_read>
801034aa:	8b 55 08             	mov    0x8(%ebp),%edx
801034ad:	89 42 14             	mov    %eax,0x14(%edx)
}
801034b0:	c9                   	leave  
801034b1:	c3                   	ret    

801034b2 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801034b2:	55                   	push   %ebp
801034b3:	89 e5                	mov    %esp,%ebp
801034b5:	57                   	push   %edi
801034b6:	56                   	push   %esi
801034b7:	53                   	push   %ebx
801034b8:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801034bb:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801034c2:	e8 3f ff ff ff       	call   80103406 <cmos_read>
801034c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801034ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801034cd:	83 e0 04             	and    $0x4,%eax
801034d0:	85 c0                	test   %eax,%eax
801034d2:	0f 94 c0             	sete   %al
801034d5:	0f b6 c0             	movzbl %al,%eax
801034d8:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801034db:	8d 45 c8             	lea    -0x38(%ebp),%eax
801034de:	89 04 24             	mov    %eax,(%esp)
801034e1:	e8 59 ff ff ff       	call   8010343f <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801034e6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801034ed:	e8 14 ff ff ff       	call   80103406 <cmos_read>
801034f2:	25 80 00 00 00       	and    $0x80,%eax
801034f7:	85 c0                	test   %eax,%eax
801034f9:	74 02                	je     801034fd <cmostime+0x4b>
        continue;
801034fb:	eb 36                	jmp    80103533 <cmostime+0x81>
    fill_rtcdate(&t2);
801034fd:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103500:	89 04 24             	mov    %eax,(%esp)
80103503:	e8 37 ff ff ff       	call   8010343f <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103508:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010350f:	00 
80103510:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103513:	89 44 24 04          	mov    %eax,0x4(%esp)
80103517:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010351a:	89 04 24             	mov    %eax,(%esp)
8010351d:	e8 57 22 00 00       	call   80105779 <memcmp>
80103522:	85 c0                	test   %eax,%eax
80103524:	75 0d                	jne    80103533 <cmostime+0x81>
      break;
80103526:	90                   	nop
  }

  // convert
  if(bcd) {
80103527:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010352b:	0f 84 ac 00 00 00    	je     801035dd <cmostime+0x12b>
80103531:	eb 02                	jmp    80103535 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103533:	eb a6                	jmp    801034db <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103535:	8b 45 c8             	mov    -0x38(%ebp),%eax
80103538:	c1 e8 04             	shr    $0x4,%eax
8010353b:	89 c2                	mov    %eax,%edx
8010353d:	89 d0                	mov    %edx,%eax
8010353f:	c1 e0 02             	shl    $0x2,%eax
80103542:	01 d0                	add    %edx,%eax
80103544:	01 c0                	add    %eax,%eax
80103546:	8b 55 c8             	mov    -0x38(%ebp),%edx
80103549:	83 e2 0f             	and    $0xf,%edx
8010354c:	01 d0                	add    %edx,%eax
8010354e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103551:	8b 45 cc             	mov    -0x34(%ebp),%eax
80103554:	c1 e8 04             	shr    $0x4,%eax
80103557:	89 c2                	mov    %eax,%edx
80103559:	89 d0                	mov    %edx,%eax
8010355b:	c1 e0 02             	shl    $0x2,%eax
8010355e:	01 d0                	add    %edx,%eax
80103560:	01 c0                	add    %eax,%eax
80103562:	8b 55 cc             	mov    -0x34(%ebp),%edx
80103565:	83 e2 0f             	and    $0xf,%edx
80103568:	01 d0                	add    %edx,%eax
8010356a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
8010356d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103570:	c1 e8 04             	shr    $0x4,%eax
80103573:	89 c2                	mov    %eax,%edx
80103575:	89 d0                	mov    %edx,%eax
80103577:	c1 e0 02             	shl    $0x2,%eax
8010357a:	01 d0                	add    %edx,%eax
8010357c:	01 c0                	add    %eax,%eax
8010357e:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103581:	83 e2 0f             	and    $0xf,%edx
80103584:	01 d0                	add    %edx,%eax
80103586:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103589:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010358c:	c1 e8 04             	shr    $0x4,%eax
8010358f:	89 c2                	mov    %eax,%edx
80103591:	89 d0                	mov    %edx,%eax
80103593:	c1 e0 02             	shl    $0x2,%eax
80103596:	01 d0                	add    %edx,%eax
80103598:	01 c0                	add    %eax,%eax
8010359a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010359d:	83 e2 0f             	and    $0xf,%edx
801035a0:	01 d0                	add    %edx,%eax
801035a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
801035a5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801035a8:	c1 e8 04             	shr    $0x4,%eax
801035ab:	89 c2                	mov    %eax,%edx
801035ad:	89 d0                	mov    %edx,%eax
801035af:	c1 e0 02             	shl    $0x2,%eax
801035b2:	01 d0                	add    %edx,%eax
801035b4:	01 c0                	add    %eax,%eax
801035b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
801035b9:	83 e2 0f             	and    $0xf,%edx
801035bc:	01 d0                	add    %edx,%eax
801035be:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
801035c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
801035c4:	c1 e8 04             	shr    $0x4,%eax
801035c7:	89 c2                	mov    %eax,%edx
801035c9:	89 d0                	mov    %edx,%eax
801035cb:	c1 e0 02             	shl    $0x2,%eax
801035ce:	01 d0                	add    %edx,%eax
801035d0:	01 c0                	add    %eax,%eax
801035d2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801035d5:	83 e2 0f             	and    $0xf,%edx
801035d8:	01 d0                	add    %edx,%eax
801035da:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
801035dd:	8b 45 08             	mov    0x8(%ebp),%eax
801035e0:	89 c2                	mov    %eax,%edx
801035e2:	8d 5d c8             	lea    -0x38(%ebp),%ebx
801035e5:	b8 06 00 00 00       	mov    $0x6,%eax
801035ea:	89 d7                	mov    %edx,%edi
801035ec:	89 de                	mov    %ebx,%esi
801035ee:	89 c1                	mov    %eax,%ecx
801035f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801035f2:	8b 45 08             	mov    0x8(%ebp),%eax
801035f5:	8b 40 14             	mov    0x14(%eax),%eax
801035f8:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801035fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103601:	89 50 14             	mov    %edx,0x14(%eax)
}
80103604:	83 c4 5c             	add    $0x5c,%esp
80103607:	5b                   	pop    %ebx
80103608:	5e                   	pop    %esi
80103609:	5f                   	pop    %edi
8010360a:	5d                   	pop    %ebp
8010360b:	c3                   	ret    

8010360c <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010360c:	55                   	push   %ebp
8010360d:	89 e5                	mov    %esp,%ebp
8010360f:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103612:	c7 44 24 04 99 9b 10 	movl   $0x80109b99,0x4(%esp)
80103619:	80 
8010361a:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103621:	e8 58 1e 00 00       	call   8010547e <initlock>
  readsb(dev, &sb);
80103626:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103629:	89 44 24 04          	mov    %eax,0x4(%esp)
8010362d:	8b 45 08             	mov    0x8(%ebp),%eax
80103630:	89 04 24             	mov    %eax,(%esp)
80103633:	e8 88 de ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
80103638:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010363b:	a3 f4 5b 11 80       	mov    %eax,0x80115bf4
  log.size = sb.nlog;
80103640:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103643:	a3 f8 5b 11 80       	mov    %eax,0x80115bf8
  log.dev = dev;
80103648:	8b 45 08             	mov    0x8(%ebp),%eax
8010364b:	a3 04 5c 11 80       	mov    %eax,0x80115c04
  recover_from_log();
80103650:	e8 95 01 00 00       	call   801037ea <recover_from_log>
}
80103655:	c9                   	leave  
80103656:	c3                   	ret    

80103657 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103657:	55                   	push   %ebp
80103658:	89 e5                	mov    %esp,%ebp
8010365a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010365d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103664:	e9 89 00 00 00       	jmp    801036f2 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103669:	8b 15 f4 5b 11 80    	mov    0x80115bf4,%edx
8010366f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103672:	01 d0                	add    %edx,%eax
80103674:	40                   	inc    %eax
80103675:	89 c2                	mov    %eax,%edx
80103677:	a1 04 5c 11 80       	mov    0x80115c04,%eax
8010367c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103680:	89 04 24             	mov    %eax,(%esp)
80103683:	e8 2d cb ff ff       	call   801001b5 <bread>
80103688:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010368b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010368e:	83 c0 10             	add    $0x10,%eax
80103691:	8b 04 85 cc 5b 11 80 	mov    -0x7feea434(,%eax,4),%eax
80103698:	89 c2                	mov    %eax,%edx
8010369a:	a1 04 5c 11 80       	mov    0x80115c04,%eax
8010369f:	89 54 24 04          	mov    %edx,0x4(%esp)
801036a3:	89 04 24             	mov    %eax,(%esp)
801036a6:	e8 0a cb ff ff       	call   801001b5 <bread>
801036ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801036ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036b1:	8d 50 5c             	lea    0x5c(%eax),%edx
801036b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036b7:	83 c0 5c             	add    $0x5c,%eax
801036ba:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036c1:	00 
801036c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801036c6:	89 04 24             	mov    %eax,(%esp)
801036c9:	e8 fd 20 00 00       	call   801057cb <memmove>
    bwrite(dbuf);  // write dst to disk
801036ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036d1:	89 04 24             	mov    %eax,(%esp)
801036d4:	e8 13 cb ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
801036d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036dc:	89 04 24             	mov    %eax,(%esp)
801036df:	e8 48 cb ff ff       	call   8010022c <brelse>
    brelse(dbuf);
801036e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036e7:	89 04 24             	mov    %eax,(%esp)
801036ea:	e8 3d cb ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036ef:	ff 45 f4             	incl   -0xc(%ebp)
801036f2:	a1 08 5c 11 80       	mov    0x80115c08,%eax
801036f7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036fa:	0f 8f 69 ff ff ff    	jg     80103669 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103700:	c9                   	leave  
80103701:	c3                   	ret    

80103702 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103702:	55                   	push   %ebp
80103703:	89 e5                	mov    %esp,%ebp
80103705:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103708:	a1 f4 5b 11 80       	mov    0x80115bf4,%eax
8010370d:	89 c2                	mov    %eax,%edx
8010370f:	a1 04 5c 11 80       	mov    0x80115c04,%eax
80103714:	89 54 24 04          	mov    %edx,0x4(%esp)
80103718:	89 04 24             	mov    %eax,(%esp)
8010371b:	e8 95 ca ff ff       	call   801001b5 <bread>
80103720:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103726:	83 c0 5c             	add    $0x5c,%eax
80103729:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
8010372c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010372f:	8b 00                	mov    (%eax),%eax
80103731:	a3 08 5c 11 80       	mov    %eax,0x80115c08
  for (i = 0; i < log.lh.n; i++) {
80103736:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010373d:	eb 1a                	jmp    80103759 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
8010373f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103742:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103745:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103749:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010374c:	83 c2 10             	add    $0x10,%edx
8010374f:	89 04 95 cc 5b 11 80 	mov    %eax,-0x7feea434(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103756:	ff 45 f4             	incl   -0xc(%ebp)
80103759:	a1 08 5c 11 80       	mov    0x80115c08,%eax
8010375e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103761:	7f dc                	jg     8010373f <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103763:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103766:	89 04 24             	mov    %eax,(%esp)
80103769:	e8 be ca ff ff       	call   8010022c <brelse>
}
8010376e:	c9                   	leave  
8010376f:	c3                   	ret    

80103770 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103770:	55                   	push   %ebp
80103771:	89 e5                	mov    %esp,%ebp
80103773:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103776:	a1 f4 5b 11 80       	mov    0x80115bf4,%eax
8010377b:	89 c2                	mov    %eax,%edx
8010377d:	a1 04 5c 11 80       	mov    0x80115c04,%eax
80103782:	89 54 24 04          	mov    %edx,0x4(%esp)
80103786:	89 04 24             	mov    %eax,(%esp)
80103789:	e8 27 ca ff ff       	call   801001b5 <bread>
8010378e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103794:	83 c0 5c             	add    $0x5c,%eax
80103797:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010379a:	8b 15 08 5c 11 80    	mov    0x80115c08,%edx
801037a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037a3:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801037a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037ac:	eb 1a                	jmp    801037c8 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801037ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b1:	83 c0 10             	add    $0x10,%eax
801037b4:	8b 0c 85 cc 5b 11 80 	mov    -0x7feea434(,%eax,4),%ecx
801037bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037c1:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801037c5:	ff 45 f4             	incl   -0xc(%ebp)
801037c8:	a1 08 5c 11 80       	mov    0x80115c08,%eax
801037cd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037d0:	7f dc                	jg     801037ae <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801037d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037d5:	89 04 24             	mov    %eax,(%esp)
801037d8:	e8 0f ca ff ff       	call   801001ec <bwrite>
  brelse(buf);
801037dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037e0:	89 04 24             	mov    %eax,(%esp)
801037e3:	e8 44 ca ff ff       	call   8010022c <brelse>
}
801037e8:	c9                   	leave  
801037e9:	c3                   	ret    

801037ea <recover_from_log>:

static void
recover_from_log(void)
{
801037ea:	55                   	push   %ebp
801037eb:	89 e5                	mov    %esp,%ebp
801037ed:	83 ec 08             	sub    $0x8,%esp
  read_head();
801037f0:	e8 0d ff ff ff       	call   80103702 <read_head>
  install_trans(); // if committed, copy from log to disk
801037f5:	e8 5d fe ff ff       	call   80103657 <install_trans>
  log.lh.n = 0;
801037fa:	c7 05 08 5c 11 80 00 	movl   $0x0,0x80115c08
80103801:	00 00 00 
  write_head(); // clear the log
80103804:	e8 67 ff ff ff       	call   80103770 <write_head>
}
80103809:	c9                   	leave  
8010380a:	c3                   	ret    

8010380b <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010380b:	55                   	push   %ebp
8010380c:	89 e5                	mov    %esp,%ebp
8010380e:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103811:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103818:	e8 82 1c 00 00       	call   8010549f <acquire>
  while(1){
    if(log.committing){
8010381d:	a1 00 5c 11 80       	mov    0x80115c00,%eax
80103822:	85 c0                	test   %eax,%eax
80103824:	74 16                	je     8010383c <begin_op+0x31>
      sleep(&log, &log.lock);
80103826:	c7 44 24 04 c0 5b 11 	movl   $0x80115bc0,0x4(%esp)
8010382d:	80 
8010382e:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103835:	e8 aa 15 00 00       	call   80104de4 <sleep>
8010383a:	eb 4d                	jmp    80103889 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010383c:	8b 15 08 5c 11 80    	mov    0x80115c08,%edx
80103842:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
80103847:	8d 48 01             	lea    0x1(%eax),%ecx
8010384a:	89 c8                	mov    %ecx,%eax
8010384c:	c1 e0 02             	shl    $0x2,%eax
8010384f:	01 c8                	add    %ecx,%eax
80103851:	01 c0                	add    %eax,%eax
80103853:	01 d0                	add    %edx,%eax
80103855:	83 f8 1e             	cmp    $0x1e,%eax
80103858:	7e 16                	jle    80103870 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010385a:	c7 44 24 04 c0 5b 11 	movl   $0x80115bc0,0x4(%esp)
80103861:	80 
80103862:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103869:	e8 76 15 00 00       	call   80104de4 <sleep>
8010386e:	eb 19                	jmp    80103889 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103870:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
80103875:	40                   	inc    %eax
80103876:	a3 fc 5b 11 80       	mov    %eax,0x80115bfc
      release(&log.lock);
8010387b:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103882:	e8 82 1c 00 00       	call   80105509 <release>
      break;
80103887:	eb 02                	jmp    8010388b <begin_op+0x80>
    }
  }
80103889:	eb 92                	jmp    8010381d <begin_op+0x12>
}
8010388b:	c9                   	leave  
8010388c:	c3                   	ret    

8010388d <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010388d:	55                   	push   %ebp
8010388e:	89 e5                	mov    %esp,%ebp
80103890:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103893:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010389a:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801038a1:	e8 f9 1b 00 00       	call   8010549f <acquire>
  log.outstanding -= 1;
801038a6:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
801038ab:	48                   	dec    %eax
801038ac:	a3 fc 5b 11 80       	mov    %eax,0x80115bfc
  if(log.committing)
801038b1:	a1 00 5c 11 80       	mov    0x80115c00,%eax
801038b6:	85 c0                	test   %eax,%eax
801038b8:	74 0c                	je     801038c6 <end_op+0x39>
    panic("log.committing");
801038ba:	c7 04 24 9d 9b 10 80 	movl   $0x80109b9d,(%esp)
801038c1:	e8 8e cc ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
801038c6:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
801038cb:	85 c0                	test   %eax,%eax
801038cd:	75 13                	jne    801038e2 <end_op+0x55>
    do_commit = 1;
801038cf:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801038d6:	c7 05 00 5c 11 80 01 	movl   $0x1,0x80115c00
801038dd:	00 00 00 
801038e0:	eb 0c                	jmp    801038ee <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801038e2:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801038e9:	e8 cd 15 00 00       	call   80104ebb <wakeup>
  }
  release(&log.lock);
801038ee:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
801038f5:	e8 0f 1c 00 00       	call   80105509 <release>

  if(do_commit){
801038fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801038fe:	74 33                	je     80103933 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103900:	e8 db 00 00 00       	call   801039e0 <commit>
    acquire(&log.lock);
80103905:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
8010390c:	e8 8e 1b 00 00       	call   8010549f <acquire>
    log.committing = 0;
80103911:	c7 05 00 5c 11 80 00 	movl   $0x0,0x80115c00
80103918:	00 00 00 
    wakeup(&log);
8010391b:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103922:	e8 94 15 00 00       	call   80104ebb <wakeup>
    release(&log.lock);
80103927:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
8010392e:	e8 d6 1b 00 00       	call   80105509 <release>
  }
}
80103933:	c9                   	leave  
80103934:	c3                   	ret    

80103935 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103935:	55                   	push   %ebp
80103936:	89 e5                	mov    %esp,%ebp
80103938:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010393b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103942:	e9 89 00 00 00       	jmp    801039d0 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103947:	8b 15 f4 5b 11 80    	mov    0x80115bf4,%edx
8010394d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103950:	01 d0                	add    %edx,%eax
80103952:	40                   	inc    %eax
80103953:	89 c2                	mov    %eax,%edx
80103955:	a1 04 5c 11 80       	mov    0x80115c04,%eax
8010395a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010395e:	89 04 24             	mov    %eax,(%esp)
80103961:	e8 4f c8 ff ff       	call   801001b5 <bread>
80103966:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010396c:	83 c0 10             	add    $0x10,%eax
8010396f:	8b 04 85 cc 5b 11 80 	mov    -0x7feea434(,%eax,4),%eax
80103976:	89 c2                	mov    %eax,%edx
80103978:	a1 04 5c 11 80       	mov    0x80115c04,%eax
8010397d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103981:	89 04 24             	mov    %eax,(%esp)
80103984:	e8 2c c8 ff ff       	call   801001b5 <bread>
80103989:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010398c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010398f:	8d 50 5c             	lea    0x5c(%eax),%edx
80103992:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103995:	83 c0 5c             	add    $0x5c,%eax
80103998:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010399f:	00 
801039a0:	89 54 24 04          	mov    %edx,0x4(%esp)
801039a4:	89 04 24             	mov    %eax,(%esp)
801039a7:	e8 1f 1e 00 00       	call   801057cb <memmove>
    bwrite(to);  // write the log
801039ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039af:	89 04 24             	mov    %eax,(%esp)
801039b2:	e8 35 c8 ff ff       	call   801001ec <bwrite>
    brelse(from);
801039b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039ba:	89 04 24             	mov    %eax,(%esp)
801039bd:	e8 6a c8 ff ff       	call   8010022c <brelse>
    brelse(to);
801039c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039c5:	89 04 24             	mov    %eax,(%esp)
801039c8:	e8 5f c8 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801039cd:	ff 45 f4             	incl   -0xc(%ebp)
801039d0:	a1 08 5c 11 80       	mov    0x80115c08,%eax
801039d5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039d8:	0f 8f 69 ff ff ff    	jg     80103947 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
801039de:	c9                   	leave  
801039df:	c3                   	ret    

801039e0 <commit>:

static void
commit()
{
801039e0:	55                   	push   %ebp
801039e1:	89 e5                	mov    %esp,%ebp
801039e3:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801039e6:	a1 08 5c 11 80       	mov    0x80115c08,%eax
801039eb:	85 c0                	test   %eax,%eax
801039ed:	7e 1e                	jle    80103a0d <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801039ef:	e8 41 ff ff ff       	call   80103935 <write_log>
    write_head();    // Write header to disk -- the real commit
801039f4:	e8 77 fd ff ff       	call   80103770 <write_head>
    install_trans(); // Now install writes to home locations
801039f9:	e8 59 fc ff ff       	call   80103657 <install_trans>
    log.lh.n = 0;
801039fe:	c7 05 08 5c 11 80 00 	movl   $0x0,0x80115c08
80103a05:	00 00 00 
    write_head();    // Erase the transaction from the log
80103a08:	e8 63 fd ff ff       	call   80103770 <write_head>
  }
}
80103a0d:	c9                   	leave  
80103a0e:	c3                   	ret    

80103a0f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103a0f:	55                   	push   %ebp
80103a10:	89 e5                	mov    %esp,%ebp
80103a12:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103a15:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103a1a:	83 f8 1d             	cmp    $0x1d,%eax
80103a1d:	7f 10                	jg     80103a2f <log_write+0x20>
80103a1f:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103a24:	8b 15 f8 5b 11 80    	mov    0x80115bf8,%edx
80103a2a:	4a                   	dec    %edx
80103a2b:	39 d0                	cmp    %edx,%eax
80103a2d:	7c 0c                	jl     80103a3b <log_write+0x2c>
    panic("too big a transaction");
80103a2f:	c7 04 24 ac 9b 10 80 	movl   $0x80109bac,(%esp)
80103a36:	e8 19 cb ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103a3b:	a1 fc 5b 11 80       	mov    0x80115bfc,%eax
80103a40:	85 c0                	test   %eax,%eax
80103a42:	7f 0c                	jg     80103a50 <log_write+0x41>
    panic("log_write outside of trans");
80103a44:	c7 04 24 c2 9b 10 80 	movl   $0x80109bc2,(%esp)
80103a4b:	e8 04 cb ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103a50:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103a57:	e8 43 1a 00 00       	call   8010549f <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103a5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a63:	eb 1e                	jmp    80103a83 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a68:	83 c0 10             	add    $0x10,%eax
80103a6b:	8b 04 85 cc 5b 11 80 	mov    -0x7feea434(,%eax,4),%eax
80103a72:	89 c2                	mov    %eax,%edx
80103a74:	8b 45 08             	mov    0x8(%ebp),%eax
80103a77:	8b 40 08             	mov    0x8(%eax),%eax
80103a7a:	39 c2                	cmp    %eax,%edx
80103a7c:	75 02                	jne    80103a80 <log_write+0x71>
      break;
80103a7e:	eb 0d                	jmp    80103a8d <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103a80:	ff 45 f4             	incl   -0xc(%ebp)
80103a83:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103a88:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a8b:	7f d8                	jg     80103a65 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103a90:	8b 40 08             	mov    0x8(%eax),%eax
80103a93:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a96:	83 c2 10             	add    $0x10,%edx
80103a99:	89 04 95 cc 5b 11 80 	mov    %eax,-0x7feea434(,%edx,4)
  if (i == log.lh.n)
80103aa0:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103aa5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103aa8:	75 0b                	jne    80103ab5 <log_write+0xa6>
    log.lh.n++;
80103aaa:	a1 08 5c 11 80       	mov    0x80115c08,%eax
80103aaf:	40                   	inc    %eax
80103ab0:	a3 08 5c 11 80       	mov    %eax,0x80115c08
  b->flags |= B_DIRTY; // prevent eviction
80103ab5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ab8:	8b 00                	mov    (%eax),%eax
80103aba:	83 c8 04             	or     $0x4,%eax
80103abd:	89 c2                	mov    %eax,%edx
80103abf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac2:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103ac4:	c7 04 24 c0 5b 11 80 	movl   $0x80115bc0,(%esp)
80103acb:	e8 39 1a 00 00       	call   80105509 <release>
}
80103ad0:	c9                   	leave  
80103ad1:	c3                   	ret    
	...

80103ad4 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103ad4:	55                   	push   %ebp
80103ad5:	89 e5                	mov    %esp,%ebp
80103ad7:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103ada:	8b 55 08             	mov    0x8(%ebp),%edx
80103add:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ae0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103ae3:	f0 87 02             	lock xchg %eax,(%edx)
80103ae6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103ae9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103aec:	c9                   	leave  
80103aed:	c3                   	ret    

80103aee <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103aee:	55                   	push   %ebp
80103aef:	89 e5                	mov    %esp,%ebp
80103af1:	83 e4 f0             	and    $0xfffffff0,%esp
80103af4:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103af7:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103afe:	80 
80103aff:	c7 04 24 f0 8c 11 80 	movl   $0x80118cf0,(%esp)
80103b06:	e8 05 f2 ff ff       	call   80102d10 <kinit1>
  kvmalloc();      // kernel page table
80103b0b:	e8 43 4d 00 00       	call   80108853 <kvmalloc>
  mpinit();        // detect other processors
80103b10:	e8 f4 03 00 00       	call   80103f09 <mpinit>
  lapicinit();     // interrupt controller
80103b15:	e8 4e f6 ff ff       	call   80103168 <lapicinit>
  seginit();       // segment descriptors
80103b1a:	e8 1c 48 00 00       	call   8010833b <seginit>
  picinit();       // disable pic
80103b1f:	e8 34 05 00 00       	call   80104058 <picinit>
  ioapicinit();    // another interrupt controller
80103b24:	e8 04 f1 ff ff       	call   80102c2d <ioapicinit>
  consoleinit();   // console hardware
80103b29:	e8 c1 d0 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103b2e:	e8 94 3b 00 00       	call   801076c7 <uartinit>
  pinit();         // process table
80103b33:	e8 16 09 00 00       	call   8010444e <pinit>
  tvinit();        // trap vectors
80103b38:	e8 57 37 00 00       	call   80107294 <tvinit>
  binit();         // buffer cache
80103b3d:	e8 f2 c4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103b42:	e8 9f d5 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
80103b47:	e8 ed ec ff ff       	call   80102839 <ideinit>
  startothers();   // start other processors
80103b4c:	e8 b3 00 00 00       	call   80103c04 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103b51:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103b58:	8e 
80103b59:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103b60:	e8 e3 f1 ff ff       	call   80102d48 <kinit2>
  freebytes = (P2V(4*1024*1024) - (void*)end) + (P2V(PHYSTOP) - P2V(4*1024*1024));
80103b65:	b8 f0 8c 11 80       	mov    $0x80118cf0,%eax
80103b6a:	ba 00 00 00 8e       	mov    $0x8e000000,%edx
80103b6f:	29 c2                	sub    %eax,%edx
80103b71:	89 d0                	mov    %edx,%eax
80103b73:	a3 84 5c 11 80       	mov    %eax,0x80115c84
  cprintf("MEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEMEME: %d\n", freebytes/4096);
80103b78:	a1 84 5c 11 80       	mov    0x80115c84,%eax
80103b7d:	c1 e8 0c             	shr    $0xc,%eax
80103b80:	89 44 24 04          	mov    %eax,0x4(%esp)
80103b84:	c7 04 24 e0 9b 10 80 	movl   $0x80109be0,(%esp)
80103b8b:	e8 31 c8 ff ff       	call   801003c1 <cprintf>
  userinit();      // first user process
80103b90:	e8 e3 0a 00 00       	call   80104678 <userinit>
  container_init();
80103b95:	e8 26 5b 00 00       	call   801096c0 <container_init>
  mpmain();        // finish this processor's setup
80103b9a:	e8 1a 00 00 00       	call   80103bb9 <mpmain>

80103b9f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103b9f:	55                   	push   %ebp
80103ba0:	89 e5                	mov    %esp,%ebp
80103ba2:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103ba5:	e8 c0 4c 00 00       	call   8010886a <switchkvm>
  seginit();
80103baa:	e8 8c 47 00 00       	call   8010833b <seginit>
  lapicinit();
80103baf:	e8 b4 f5 ff ff       	call   80103168 <lapicinit>
  mpmain();
80103bb4:	e8 00 00 00 00       	call   80103bb9 <mpmain>

80103bb9 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103bb9:	55                   	push   %ebp
80103bba:	89 e5                	mov    %esp,%ebp
80103bbc:	53                   	push   %ebx
80103bbd:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103bc0:	e8 a5 08 00 00       	call   8010446a <cpuid>
80103bc5:	89 c3                	mov    %eax,%ebx
80103bc7:	e8 9e 08 00 00       	call   8010446a <cpuid>
80103bcc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bd4:	c7 04 24 1c 9c 10 80 	movl   $0x80109c1c,(%esp)
80103bdb:	e8 e1 c7 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103be0:	e8 0c 38 00 00       	call   801073f1 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103be5:	e8 c5 08 00 00       	call   801044af <mycpu>
80103bea:	05 a0 00 00 00       	add    $0xa0,%eax
80103bef:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103bf6:	00 
80103bf7:	89 04 24             	mov    %eax,(%esp)
80103bfa:	e8 d5 fe ff ff       	call   80103ad4 <xchg>
  scheduler();     // start running processes
80103bff:	e8 13 10 00 00       	call   80104c17 <scheduler>

80103c04 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103c04:	55                   	push   %ebp
80103c05:	89 e5                	mov    %esp,%ebp
80103c07:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103c0a:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103c11:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103c16:	89 44 24 08          	mov    %eax,0x8(%esp)
80103c1a:	c7 44 24 04 8c d5 10 	movl   $0x8010d58c,0x4(%esp)
80103c21:	80 
80103c22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c25:	89 04 24             	mov    %eax,(%esp)
80103c28:	e8 9e 1b 00 00       	call   801057cb <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103c2d:	c7 45 f4 c0 5c 11 80 	movl   $0x80115cc0,-0xc(%ebp)
80103c34:	eb 75                	jmp    80103cab <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103c36:	e8 74 08 00 00       	call   801044af <mycpu>
80103c3b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103c3e:	75 02                	jne    80103c42 <startothers+0x3e>
      continue;
80103c40:	eb 62                	jmp    80103ca4 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103c42:	e8 45 f2 ff ff       	call   80102e8c <kalloc>
80103c47:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103c4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c4d:	83 e8 04             	sub    $0x4,%eax
80103c50:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103c53:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103c59:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c5e:	83 e8 08             	sub    $0x8,%eax
80103c61:	c7 00 9f 3b 10 80    	movl   $0x80103b9f,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c6a:	8d 50 f4             	lea    -0xc(%eax),%edx
80103c6d:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103c72:	05 00 00 00 80       	add    $0x80000000,%eax
80103c77:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c7c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c85:	8a 00                	mov    (%eax),%al
80103c87:	0f b6 c0             	movzbl %al,%eax
80103c8a:	89 54 24 04          	mov    %edx,0x4(%esp)
80103c8e:	89 04 24             	mov    %eax,(%esp)
80103c91:	e8 77 f6 ff ff       	call   8010330d <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103c96:	90                   	nop
80103c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9a:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103ca0:	85 c0                	test   %eax,%eax
80103ca2:	74 f3                	je     80103c97 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103ca4:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103cab:	a1 40 62 11 80       	mov    0x80116240,%eax
80103cb0:	89 c2                	mov    %eax,%edx
80103cb2:	89 d0                	mov    %edx,%eax
80103cb4:	c1 e0 02             	shl    $0x2,%eax
80103cb7:	01 d0                	add    %edx,%eax
80103cb9:	01 c0                	add    %eax,%eax
80103cbb:	01 d0                	add    %edx,%eax
80103cbd:	c1 e0 04             	shl    $0x4,%eax
80103cc0:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
80103cc5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cc8:	0f 87 68 ff ff ff    	ja     80103c36 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103cce:	c9                   	leave  
80103ccf:	c3                   	ret    

80103cd0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103cd0:	55                   	push   %ebp
80103cd1:	89 e5                	mov    %esp,%ebp
80103cd3:	83 ec 14             	sub    $0x14,%esp
80103cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103cdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ce0:	89 c2                	mov    %eax,%edx
80103ce2:	ec                   	in     (%dx),%al
80103ce3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ce6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103ce9:	c9                   	leave  
80103cea:	c3                   	ret    

80103ceb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103ceb:	55                   	push   %ebp
80103cec:	89 e5                	mov    %esp,%ebp
80103cee:	83 ec 08             	sub    $0x8,%esp
80103cf1:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cf7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103cfb:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103cfe:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d01:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d04:	ee                   	out    %al,(%dx)
}
80103d05:	c9                   	leave  
80103d06:	c3                   	ret    

80103d07 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103d07:	55                   	push   %ebp
80103d08:	89 e5                	mov    %esp,%ebp
80103d0a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103d0d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103d14:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103d1b:	eb 13                	jmp    80103d30 <sum+0x29>
    sum += addr[i];
80103d1d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d20:	8b 45 08             	mov    0x8(%ebp),%eax
80103d23:	01 d0                	add    %edx,%eax
80103d25:	8a 00                	mov    (%eax),%al
80103d27:	0f b6 c0             	movzbl %al,%eax
80103d2a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103d2d:	ff 45 fc             	incl   -0x4(%ebp)
80103d30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103d33:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103d36:	7c e5                	jl     80103d1d <sum+0x16>
    sum += addr[i];
  return sum;
80103d38:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103d3b:	c9                   	leave  
80103d3c:	c3                   	ret    

80103d3d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103d3d:	55                   	push   %ebp
80103d3e:	89 e5                	mov    %esp,%ebp
80103d40:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103d43:	8b 45 08             	mov    0x8(%ebp),%eax
80103d46:	05 00 00 00 80       	add    $0x80000000,%eax
80103d4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103d4e:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d54:	01 d0                	add    %edx,%eax
80103d56:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d5f:	eb 3f                	jmp    80103da0 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103d61:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103d68:	00 
80103d69:	c7 44 24 04 30 9c 10 	movl   $0x80109c30,0x4(%esp)
80103d70:	80 
80103d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d74:	89 04 24             	mov    %eax,(%esp)
80103d77:	e8 fd 19 00 00       	call   80105779 <memcmp>
80103d7c:	85 c0                	test   %eax,%eax
80103d7e:	75 1c                	jne    80103d9c <mpsearch1+0x5f>
80103d80:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103d87:	00 
80103d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8b:	89 04 24             	mov    %eax,(%esp)
80103d8e:	e8 74 ff ff ff       	call   80103d07 <sum>
80103d93:	84 c0                	test   %al,%al
80103d95:	75 05                	jne    80103d9c <mpsearch1+0x5f>
      return (struct mp*)p;
80103d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d9a:	eb 11                	jmp    80103dad <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103d9c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103da6:	72 b9                	jb     80103d61 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103da8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103dad:	c9                   	leave  
80103dae:	c3                   	ret    

80103daf <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103daf:	55                   	push   %ebp
80103db0:	89 e5                	mov    %esp,%ebp
80103db2:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103db5:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dbf:	83 c0 0f             	add    $0xf,%eax
80103dc2:	8a 00                	mov    (%eax),%al
80103dc4:	0f b6 c0             	movzbl %al,%eax
80103dc7:	c1 e0 08             	shl    $0x8,%eax
80103dca:	89 c2                	mov    %eax,%edx
80103dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcf:	83 c0 0e             	add    $0xe,%eax
80103dd2:	8a 00                	mov    (%eax),%al
80103dd4:	0f b6 c0             	movzbl %al,%eax
80103dd7:	09 d0                	or     %edx,%eax
80103dd9:	c1 e0 04             	shl    $0x4,%eax
80103ddc:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ddf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103de3:	74 21                	je     80103e06 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103de5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103dec:	00 
80103ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df0:	89 04 24             	mov    %eax,(%esp)
80103df3:	e8 45 ff ff ff       	call   80103d3d <mpsearch1>
80103df8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103dfb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103dff:	74 4e                	je     80103e4f <mpsearch+0xa0>
      return mp;
80103e01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e04:	eb 5d                	jmp    80103e63 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e09:	83 c0 14             	add    $0x14,%eax
80103e0c:	8a 00                	mov    (%eax),%al
80103e0e:	0f b6 c0             	movzbl %al,%eax
80103e11:	c1 e0 08             	shl    $0x8,%eax
80103e14:	89 c2                	mov    %eax,%edx
80103e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e19:	83 c0 13             	add    $0x13,%eax
80103e1c:	8a 00                	mov    (%eax),%al
80103e1e:	0f b6 c0             	movzbl %al,%eax
80103e21:	09 d0                	or     %edx,%eax
80103e23:	c1 e0 0a             	shl    $0xa,%eax
80103e26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e2c:	2d 00 04 00 00       	sub    $0x400,%eax
80103e31:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103e38:	00 
80103e39:	89 04 24             	mov    %eax,(%esp)
80103e3c:	e8 fc fe ff ff       	call   80103d3d <mpsearch1>
80103e41:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e44:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e48:	74 05                	je     80103e4f <mpsearch+0xa0>
      return mp;
80103e4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e4d:	eb 14                	jmp    80103e63 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103e4f:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103e56:	00 
80103e57:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103e5e:	e8 da fe ff ff       	call   80103d3d <mpsearch1>
}
80103e63:	c9                   	leave  
80103e64:	c3                   	ret    

80103e65 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103e65:	55                   	push   %ebp
80103e66:	89 e5                	mov    %esp,%ebp
80103e68:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103e6b:	e8 3f ff ff ff       	call   80103daf <mpsearch>
80103e70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e77:	74 0a                	je     80103e83 <mpconfig+0x1e>
80103e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7c:	8b 40 04             	mov    0x4(%eax),%eax
80103e7f:	85 c0                	test   %eax,%eax
80103e81:	75 07                	jne    80103e8a <mpconfig+0x25>
    return 0;
80103e83:	b8 00 00 00 00       	mov    $0x0,%eax
80103e88:	eb 7d                	jmp    80103f07 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e8d:	8b 40 04             	mov    0x4(%eax),%eax
80103e90:	05 00 00 00 80       	add    $0x80000000,%eax
80103e95:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103e98:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103e9f:	00 
80103ea0:	c7 44 24 04 35 9c 10 	movl   $0x80109c35,0x4(%esp)
80103ea7:	80 
80103ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103eab:	89 04 24             	mov    %eax,(%esp)
80103eae:	e8 c6 18 00 00       	call   80105779 <memcmp>
80103eb3:	85 c0                	test   %eax,%eax
80103eb5:	74 07                	je     80103ebe <mpconfig+0x59>
    return 0;
80103eb7:	b8 00 00 00 00       	mov    $0x0,%eax
80103ebc:	eb 49                	jmp    80103f07 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ec1:	8a 40 06             	mov    0x6(%eax),%al
80103ec4:	3c 01                	cmp    $0x1,%al
80103ec6:	74 11                	je     80103ed9 <mpconfig+0x74>
80103ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ecb:	8a 40 06             	mov    0x6(%eax),%al
80103ece:	3c 04                	cmp    $0x4,%al
80103ed0:	74 07                	je     80103ed9 <mpconfig+0x74>
    return 0;
80103ed2:	b8 00 00 00 00       	mov    $0x0,%eax
80103ed7:	eb 2e                	jmp    80103f07 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103ed9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103edc:	8b 40 04             	mov    0x4(%eax),%eax
80103edf:	0f b7 c0             	movzwl %ax,%eax
80103ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ee6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ee9:	89 04 24             	mov    %eax,(%esp)
80103eec:	e8 16 fe ff ff       	call   80103d07 <sum>
80103ef1:	84 c0                	test   %al,%al
80103ef3:	74 07                	je     80103efc <mpconfig+0x97>
    return 0;
80103ef5:	b8 00 00 00 00       	mov    $0x0,%eax
80103efa:	eb 0b                	jmp    80103f07 <mpconfig+0xa2>
  *pmp = mp;
80103efc:	8b 45 08             	mov    0x8(%ebp),%eax
80103eff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f02:	89 10                	mov    %edx,(%eax)
  return conf;
80103f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f07:	c9                   	leave  
80103f08:	c3                   	ret    

80103f09 <mpinit>:

void
mpinit(void)
{
80103f09:	55                   	push   %ebp
80103f0a:	89 e5                	mov    %esp,%ebp
80103f0c:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103f0f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103f12:	89 04 24             	mov    %eax,(%esp)
80103f15:	e8 4b ff ff ff       	call   80103e65 <mpconfig>
80103f1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103f1d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103f21:	75 0c                	jne    80103f2f <mpinit+0x26>
    panic("Expect to run on an SMP");
80103f23:	c7 04 24 3a 9c 10 80 	movl   $0x80109c3a,(%esp)
80103f2a:	e8 25 c6 ff ff       	call   80100554 <panic>
  ismp = 1;
80103f2f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103f36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f39:	8b 40 24             	mov    0x24(%eax),%eax
80103f3c:	a3 a0 5b 11 80       	mov    %eax,0x80115ba0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f44:	83 c0 2c             	add    $0x2c,%eax
80103f47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f4d:	8b 40 04             	mov    0x4(%eax),%eax
80103f50:	0f b7 d0             	movzwl %ax,%edx
80103f53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f56:	01 d0                	add    %edx,%eax
80103f58:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103f5b:	eb 7d                	jmp    80103fda <mpinit+0xd1>
    switch(*p){
80103f5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f60:	8a 00                	mov    (%eax),%al
80103f62:	0f b6 c0             	movzbl %al,%eax
80103f65:	83 f8 04             	cmp    $0x4,%eax
80103f68:	77 68                	ja     80103fd2 <mpinit+0xc9>
80103f6a:	8b 04 85 74 9c 10 80 	mov    -0x7fef638c(,%eax,4),%eax
80103f71:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103f79:	a1 40 62 11 80       	mov    0x80116240,%eax
80103f7e:	83 f8 07             	cmp    $0x7,%eax
80103f81:	7f 2c                	jg     80103faf <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103f83:	8b 15 40 62 11 80    	mov    0x80116240,%edx
80103f89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f8c:	8a 48 01             	mov    0x1(%eax),%cl
80103f8f:	89 d0                	mov    %edx,%eax
80103f91:	c1 e0 02             	shl    $0x2,%eax
80103f94:	01 d0                	add    %edx,%eax
80103f96:	01 c0                	add    %eax,%eax
80103f98:	01 d0                	add    %edx,%eax
80103f9a:	c1 e0 04             	shl    $0x4,%eax
80103f9d:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
80103fa2:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103fa4:	a1 40 62 11 80       	mov    0x80116240,%eax
80103fa9:	40                   	inc    %eax
80103faa:	a3 40 62 11 80       	mov    %eax,0x80116240
      }
      p += sizeof(struct mpproc);
80103faf:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103fb3:	eb 25                	jmp    80103fda <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103fbb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103fbe:	8a 40 01             	mov    0x1(%eax),%al
80103fc1:	a2 a0 5c 11 80       	mov    %al,0x80115ca0
      p += sizeof(struct mpioapic);
80103fc6:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103fca:	eb 0e                	jmp    80103fda <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103fcc:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103fd0:	eb 08                	jmp    80103fda <mpinit+0xd1>
    default:
      ismp = 0;
80103fd2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103fd9:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdd:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103fe0:	0f 82 77 ff ff ff    	jb     80103f5d <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103fe6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103fea:	75 0c                	jne    80103ff8 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103fec:	c7 04 24 54 9c 10 80 	movl   $0x80109c54,(%esp)
80103ff3:	e8 5c c5 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103ff8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ffb:	8a 40 0c             	mov    0xc(%eax),%al
80103ffe:	84 c0                	test   %al,%al
80104000:	74 36                	je     80104038 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80104002:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80104009:	00 
8010400a:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80104011:	e8 d5 fc ff ff       	call   80103ceb <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80104016:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
8010401d:	e8 ae fc ff ff       	call   80103cd0 <inb>
80104022:	83 c8 01             	or     $0x1,%eax
80104025:	0f b6 c0             	movzbl %al,%eax
80104028:	89 44 24 04          	mov    %eax,0x4(%esp)
8010402c:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80104033:	e8 b3 fc ff ff       	call   80103ceb <outb>
  }
}
80104038:	c9                   	leave  
80104039:	c3                   	ret    
	...

8010403c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010403c:	55                   	push   %ebp
8010403d:	89 e5                	mov    %esp,%ebp
8010403f:	83 ec 08             	sub    $0x8,%esp
80104042:	8b 45 08             	mov    0x8(%ebp),%eax
80104045:	8b 55 0c             	mov    0xc(%ebp),%edx
80104048:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010404c:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010404f:	8a 45 f8             	mov    -0x8(%ebp),%al
80104052:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104055:	ee                   	out    %al,(%dx)
}
80104056:	c9                   	leave  
80104057:	c3                   	ret    

80104058 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80104058:	55                   	push   %ebp
80104059:	89 e5                	mov    %esp,%ebp
8010405b:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
8010405e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104065:	00 
80104066:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
8010406d:	e8 ca ff ff ff       	call   8010403c <outb>
  outb(IO_PIC2+1, 0xFF);
80104072:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104079:	00 
8010407a:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104081:	e8 b6 ff ff ff       	call   8010403c <outb>
}
80104086:	c9                   	leave  
80104087:	c3                   	ret    

80104088 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104088:	55                   	push   %ebp
80104089:	89 e5                	mov    %esp,%ebp
8010408b:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
8010408e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104095:	8b 45 0c             	mov    0xc(%ebp),%eax
80104098:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010409e:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a1:	8b 10                	mov    (%eax),%edx
801040a3:	8b 45 08             	mov    0x8(%ebp),%eax
801040a6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040a8:	e8 55 d0 ff ff       	call   80101102 <filealloc>
801040ad:	8b 55 08             	mov    0x8(%ebp),%edx
801040b0:	89 02                	mov    %eax,(%edx)
801040b2:	8b 45 08             	mov    0x8(%ebp),%eax
801040b5:	8b 00                	mov    (%eax),%eax
801040b7:	85 c0                	test   %eax,%eax
801040b9:	0f 84 c8 00 00 00    	je     80104187 <pipealloc+0xff>
801040bf:	e8 3e d0 ff ff       	call   80101102 <filealloc>
801040c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801040c7:	89 02                	mov    %eax,(%edx)
801040c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cc:	8b 00                	mov    (%eax),%eax
801040ce:	85 c0                	test   %eax,%eax
801040d0:	0f 84 b1 00 00 00    	je     80104187 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040d6:	e8 b1 ed ff ff       	call   80102e8c <kalloc>
801040db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040e2:	75 05                	jne    801040e9 <pipealloc+0x61>
    goto bad;
801040e4:	e9 9e 00 00 00       	jmp    80104187 <pipealloc+0xff>
  p->readopen = 1;
801040e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ec:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040f3:	00 00 00 
  p->writeopen = 1;
801040f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f9:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104100:	00 00 00 
  p->nwrite = 0;
80104103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104106:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010410d:	00 00 00 
  p->nread = 0;
80104110:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104113:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
8010411a:	00 00 00 
  initlock(&p->lock, "pipe");
8010411d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104120:	c7 44 24 04 88 9c 10 	movl   $0x80109c88,0x4(%esp)
80104127:	80 
80104128:	89 04 24             	mov    %eax,(%esp)
8010412b:	e8 4e 13 00 00       	call   8010547e <initlock>
  (*f0)->type = FD_PIPE;
80104130:	8b 45 08             	mov    0x8(%ebp),%eax
80104133:	8b 00                	mov    (%eax),%eax
80104135:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	8b 00                	mov    (%eax),%eax
80104140:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	8b 00                	mov    (%eax),%eax
80104149:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010414d:	8b 45 08             	mov    0x8(%ebp),%eax
80104150:	8b 00                	mov    (%eax),%eax
80104152:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104155:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104158:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415b:	8b 00                	mov    (%eax),%eax
8010415d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104163:	8b 45 0c             	mov    0xc(%ebp),%eax
80104166:	8b 00                	mov    (%eax),%eax
80104168:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010416c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416f:	8b 00                	mov    (%eax),%eax
80104171:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104175:	8b 45 0c             	mov    0xc(%ebp),%eax
80104178:	8b 00                	mov    (%eax),%eax
8010417a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010417d:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104180:	b8 00 00 00 00       	mov    $0x0,%eax
80104185:	eb 42                	jmp    801041c9 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80104187:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010418b:	74 0b                	je     80104198 <pipealloc+0x110>
    kfree((char*)p);
8010418d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104190:	89 04 24             	mov    %eax,(%esp)
80104193:	e8 17 ec ff ff       	call   80102daf <kfree>
  if(*f0)
80104198:	8b 45 08             	mov    0x8(%ebp),%eax
8010419b:	8b 00                	mov    (%eax),%eax
8010419d:	85 c0                	test   %eax,%eax
8010419f:	74 0d                	je     801041ae <pipealloc+0x126>
    fileclose(*f0);
801041a1:	8b 45 08             	mov    0x8(%ebp),%eax
801041a4:	8b 00                	mov    (%eax),%eax
801041a6:	89 04 24             	mov    %eax,(%esp)
801041a9:	e8 fc cf ff ff       	call   801011aa <fileclose>
  if(*f1)
801041ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801041b1:	8b 00                	mov    (%eax),%eax
801041b3:	85 c0                	test   %eax,%eax
801041b5:	74 0d                	je     801041c4 <pipealloc+0x13c>
    fileclose(*f1);
801041b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801041ba:	8b 00                	mov    (%eax),%eax
801041bc:	89 04 24             	mov    %eax,(%esp)
801041bf:	e8 e6 cf ff ff       	call   801011aa <fileclose>
  return -1;
801041c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041c9:	c9                   	leave  
801041ca:	c3                   	ret    

801041cb <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041cb:	55                   	push   %ebp
801041cc:	89 e5                	mov    %esp,%ebp
801041ce:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
801041d1:	8b 45 08             	mov    0x8(%ebp),%eax
801041d4:	89 04 24             	mov    %eax,(%esp)
801041d7:	e8 c3 12 00 00       	call   8010549f <acquire>
  if(writable){
801041dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041e0:	74 1f                	je     80104201 <pipeclose+0x36>
    p->writeopen = 0;
801041e2:	8b 45 08             	mov    0x8(%ebp),%eax
801041e5:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041ec:	00 00 00 
    wakeup(&p->nread);
801041ef:	8b 45 08             	mov    0x8(%ebp),%eax
801041f2:	05 34 02 00 00       	add    $0x234,%eax
801041f7:	89 04 24             	mov    %eax,(%esp)
801041fa:	e8 bc 0c 00 00       	call   80104ebb <wakeup>
801041ff:	eb 1d                	jmp    8010421e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010420b:	00 00 00 
    wakeup(&p->nwrite);
8010420e:	8b 45 08             	mov    0x8(%ebp),%eax
80104211:	05 38 02 00 00       	add    $0x238,%eax
80104216:	89 04 24             	mov    %eax,(%esp)
80104219:	e8 9d 0c 00 00       	call   80104ebb <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010421e:	8b 45 08             	mov    0x8(%ebp),%eax
80104221:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104227:	85 c0                	test   %eax,%eax
80104229:	75 25                	jne    80104250 <pipeclose+0x85>
8010422b:	8b 45 08             	mov    0x8(%ebp),%eax
8010422e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104234:	85 c0                	test   %eax,%eax
80104236:	75 18                	jne    80104250 <pipeclose+0x85>
    release(&p->lock);
80104238:	8b 45 08             	mov    0x8(%ebp),%eax
8010423b:	89 04 24             	mov    %eax,(%esp)
8010423e:	e8 c6 12 00 00       	call   80105509 <release>
    kfree((char*)p);
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	89 04 24             	mov    %eax,(%esp)
80104249:	e8 61 eb ff ff       	call   80102daf <kfree>
8010424e:	eb 0b                	jmp    8010425b <pipeclose+0x90>
  } else
    release(&p->lock);
80104250:	8b 45 08             	mov    0x8(%ebp),%eax
80104253:	89 04 24             	mov    %eax,(%esp)
80104256:	e8 ae 12 00 00       	call   80105509 <release>
}
8010425b:	c9                   	leave  
8010425c:	c3                   	ret    

8010425d <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010425d:	55                   	push   %ebp
8010425e:	89 e5                	mov    %esp,%ebp
80104260:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104263:	8b 45 08             	mov    0x8(%ebp),%eax
80104266:	89 04 24             	mov    %eax,(%esp)
80104269:	e8 31 12 00 00       	call   8010549f <acquire>
  for(i = 0; i < n; i++){
8010426e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104275:	e9 a3 00 00 00       	jmp    8010431d <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010427a:	eb 56                	jmp    801042d2 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
8010427c:	8b 45 08             	mov    0x8(%ebp),%eax
8010427f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104285:	85 c0                	test   %eax,%eax
80104287:	74 0c                	je     80104295 <pipewrite+0x38>
80104289:	e8 a5 02 00 00       	call   80104533 <myproc>
8010428e:	8b 40 24             	mov    0x24(%eax),%eax
80104291:	85 c0                	test   %eax,%eax
80104293:	74 15                	je     801042aa <pipewrite+0x4d>
        release(&p->lock);
80104295:	8b 45 08             	mov    0x8(%ebp),%eax
80104298:	89 04 24             	mov    %eax,(%esp)
8010429b:	e8 69 12 00 00       	call   80105509 <release>
        return -1;
801042a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042a5:	e9 9d 00 00 00       	jmp    80104347 <pipewrite+0xea>
      }
      wakeup(&p->nread);
801042aa:	8b 45 08             	mov    0x8(%ebp),%eax
801042ad:	05 34 02 00 00       	add    $0x234,%eax
801042b2:	89 04 24             	mov    %eax,(%esp)
801042b5:	e8 01 0c 00 00       	call   80104ebb <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042ba:	8b 45 08             	mov    0x8(%ebp),%eax
801042bd:	8b 55 08             	mov    0x8(%ebp),%edx
801042c0:	81 c2 38 02 00 00    	add    $0x238,%edx
801042c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801042ca:	89 14 24             	mov    %edx,(%esp)
801042cd:	e8 12 0b 00 00       	call   80104de4 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042d2:	8b 45 08             	mov    0x8(%ebp),%eax
801042d5:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042db:	8b 45 08             	mov    0x8(%ebp),%eax
801042de:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042e4:	05 00 02 00 00       	add    $0x200,%eax
801042e9:	39 c2                	cmp    %eax,%edx
801042eb:	74 8f                	je     8010427c <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042ed:	8b 45 08             	mov    0x8(%ebp),%eax
801042f0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042f6:	8d 48 01             	lea    0x1(%eax),%ecx
801042f9:	8b 55 08             	mov    0x8(%ebp),%edx
801042fc:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104302:	25 ff 01 00 00       	and    $0x1ff,%eax
80104307:	89 c1                	mov    %eax,%ecx
80104309:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010430c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010430f:	01 d0                	add    %edx,%eax
80104311:	8a 10                	mov    (%eax),%dl
80104313:	8b 45 08             	mov    0x8(%ebp),%eax
80104316:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010431a:	ff 45 f4             	incl   -0xc(%ebp)
8010431d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104320:	3b 45 10             	cmp    0x10(%ebp),%eax
80104323:	0f 8c 51 ff ff ff    	jl     8010427a <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104329:	8b 45 08             	mov    0x8(%ebp),%eax
8010432c:	05 34 02 00 00       	add    $0x234,%eax
80104331:	89 04 24             	mov    %eax,(%esp)
80104334:	e8 82 0b 00 00       	call   80104ebb <wakeup>
  release(&p->lock);
80104339:	8b 45 08             	mov    0x8(%ebp),%eax
8010433c:	89 04 24             	mov    %eax,(%esp)
8010433f:	e8 c5 11 00 00       	call   80105509 <release>
  return n;
80104344:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104347:	c9                   	leave  
80104348:	c3                   	ret    

80104349 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104349:	55                   	push   %ebp
8010434a:	89 e5                	mov    %esp,%ebp
8010434c:	53                   	push   %ebx
8010434d:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104350:	8b 45 08             	mov    0x8(%ebp),%eax
80104353:	89 04 24             	mov    %eax,(%esp)
80104356:	e8 44 11 00 00       	call   8010549f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010435b:	eb 39                	jmp    80104396 <piperead+0x4d>
    if(myproc()->killed){
8010435d:	e8 d1 01 00 00       	call   80104533 <myproc>
80104362:	8b 40 24             	mov    0x24(%eax),%eax
80104365:	85 c0                	test   %eax,%eax
80104367:	74 15                	je     8010437e <piperead+0x35>
      release(&p->lock);
80104369:	8b 45 08             	mov    0x8(%ebp),%eax
8010436c:	89 04 24             	mov    %eax,(%esp)
8010436f:	e8 95 11 00 00       	call   80105509 <release>
      return -1;
80104374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104379:	e9 b3 00 00 00       	jmp    80104431 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010437e:	8b 45 08             	mov    0x8(%ebp),%eax
80104381:	8b 55 08             	mov    0x8(%ebp),%edx
80104384:	81 c2 34 02 00 00    	add    $0x234,%edx
8010438a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010438e:	89 14 24             	mov    %edx,(%esp)
80104391:	e8 4e 0a 00 00       	call   80104de4 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104396:	8b 45 08             	mov    0x8(%ebp),%eax
80104399:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010439f:	8b 45 08             	mov    0x8(%ebp),%eax
801043a2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043a8:	39 c2                	cmp    %eax,%edx
801043aa:	75 0d                	jne    801043b9 <piperead+0x70>
801043ac:	8b 45 08             	mov    0x8(%ebp),%eax
801043af:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043b5:	85 c0                	test   %eax,%eax
801043b7:	75 a4                	jne    8010435d <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043c0:	eb 49                	jmp    8010440b <piperead+0xc2>
    if(p->nread == p->nwrite)
801043c2:	8b 45 08             	mov    0x8(%ebp),%eax
801043c5:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043cb:	8b 45 08             	mov    0x8(%ebp),%eax
801043ce:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043d4:	39 c2                	cmp    %eax,%edx
801043d6:	75 02                	jne    801043da <piperead+0x91>
      break;
801043d8:	eb 39                	jmp    80104413 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043da:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801043e0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801043e3:	8b 45 08             	mov    0x8(%ebp),%eax
801043e6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043ec:	8d 48 01             	lea    0x1(%eax),%ecx
801043ef:	8b 55 08             	mov    0x8(%ebp),%edx
801043f2:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043f8:	25 ff 01 00 00       	and    $0x1ff,%eax
801043fd:	89 c2                	mov    %eax,%edx
801043ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104402:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104406:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104408:	ff 45 f4             	incl   -0xc(%ebp)
8010440b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104411:	7c af                	jl     801043c2 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	05 38 02 00 00       	add    $0x238,%eax
8010441b:	89 04 24             	mov    %eax,(%esp)
8010441e:	e8 98 0a 00 00       	call   80104ebb <wakeup>
  release(&p->lock);
80104423:	8b 45 08             	mov    0x8(%ebp),%eax
80104426:	89 04 24             	mov    %eax,(%esp)
80104429:	e8 db 10 00 00       	call   80105509 <release>
  return i;
8010442e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104431:	83 c4 24             	add    $0x24,%esp
80104434:	5b                   	pop    %ebx
80104435:	5d                   	pop    %ebp
80104436:	c3                   	ret    
	...

80104438 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104438:	55                   	push   %ebp
80104439:	89 e5                	mov    %esp,%ebp
8010443b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010443e:	9c                   	pushf  
8010443f:	58                   	pop    %eax
80104440:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104443:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104446:	c9                   	leave  
80104447:	c3                   	ret    

80104448 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104448:	55                   	push   %ebp
80104449:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010444b:	fb                   	sti    
}
8010444c:	5d                   	pop    %ebp
8010444d:	c3                   	ret    

8010444e <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010444e:	55                   	push   %ebp
8010444f:	89 e5                	mov    %esp,%ebp
80104451:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104454:	c7 44 24 04 90 9c 10 	movl   $0x80109c90,0x4(%esp)
8010445b:	80 
8010445c:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104463:	e8 16 10 00 00       	call   8010547e <initlock>
}
80104468:	c9                   	leave  
80104469:	c3                   	ret    

8010446a <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010446a:	55                   	push   %ebp
8010446b:	89 e5                	mov    %esp,%ebp
8010446d:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104470:	e8 3a 00 00 00       	call   801044af <mycpu>
80104475:	89 c2                	mov    %eax,%edx
80104477:	b8 c0 5c 11 80       	mov    $0x80115cc0,%eax
8010447c:	29 c2                	sub    %eax,%edx
8010447e:	89 d0                	mov    %edx,%eax
80104480:	c1 f8 04             	sar    $0x4,%eax
80104483:	89 c1                	mov    %eax,%ecx
80104485:	89 ca                	mov    %ecx,%edx
80104487:	c1 e2 03             	shl    $0x3,%edx
8010448a:	01 ca                	add    %ecx,%edx
8010448c:	89 d0                	mov    %edx,%eax
8010448e:	c1 e0 05             	shl    $0x5,%eax
80104491:	29 d0                	sub    %edx,%eax
80104493:	c1 e0 02             	shl    $0x2,%eax
80104496:	01 c8                	add    %ecx,%eax
80104498:	c1 e0 03             	shl    $0x3,%eax
8010449b:	01 c8                	add    %ecx,%eax
8010449d:	89 c2                	mov    %eax,%edx
8010449f:	c1 e2 0f             	shl    $0xf,%edx
801044a2:	29 c2                	sub    %eax,%edx
801044a4:	c1 e2 02             	shl    $0x2,%edx
801044a7:	01 ca                	add    %ecx,%edx
801044a9:	89 d0                	mov    %edx,%eax
801044ab:	f7 d8                	neg    %eax
}
801044ad:	c9                   	leave  
801044ae:	c3                   	ret    

801044af <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801044af:	55                   	push   %ebp
801044b0:	89 e5                	mov    %esp,%ebp
801044b2:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801044b5:	e8 7e ff ff ff       	call   80104438 <readeflags>
801044ba:	25 00 02 00 00       	and    $0x200,%eax
801044bf:	85 c0                	test   %eax,%eax
801044c1:	74 0c                	je     801044cf <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
801044c3:	c7 04 24 98 9c 10 80 	movl   $0x80109c98,(%esp)
801044ca:	e8 85 c0 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
801044cf:	e8 ed ed ff ff       	call   801032c1 <lapicid>
801044d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801044d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801044de:	eb 3b                	jmp    8010451b <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
801044e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044e3:	89 d0                	mov    %edx,%eax
801044e5:	c1 e0 02             	shl    $0x2,%eax
801044e8:	01 d0                	add    %edx,%eax
801044ea:	01 c0                	add    %eax,%eax
801044ec:	01 d0                	add    %edx,%eax
801044ee:	c1 e0 04             	shl    $0x4,%eax
801044f1:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
801044f6:	8a 00                	mov    (%eax),%al
801044f8:	0f b6 c0             	movzbl %al,%eax
801044fb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801044fe:	75 18                	jne    80104518 <mycpu+0x69>
      return &cpus[i];
80104500:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104503:	89 d0                	mov    %edx,%eax
80104505:	c1 e0 02             	shl    $0x2,%eax
80104508:	01 d0                	add    %edx,%eax
8010450a:	01 c0                	add    %eax,%eax
8010450c:	01 d0                	add    %edx,%eax
8010450e:	c1 e0 04             	shl    $0x4,%eax
80104511:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
80104516:	eb 19                	jmp    80104531 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104518:	ff 45 f4             	incl   -0xc(%ebp)
8010451b:	a1 40 62 11 80       	mov    0x80116240,%eax
80104520:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104523:	7c bb                	jl     801044e0 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104525:	c7 04 24 be 9c 10 80 	movl   $0x80109cbe,(%esp)
8010452c:	e8 23 c0 ff ff       	call   80100554 <panic>
}
80104531:	c9                   	leave  
80104532:	c3                   	ret    

80104533 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104533:	55                   	push   %ebp
80104534:	89 e5                	mov    %esp,%ebp
80104536:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104539:	e8 c0 10 00 00       	call   801055fe <pushcli>
  c = mycpu();
8010453e:	e8 6c ff ff ff       	call   801044af <mycpu>
80104543:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104546:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104549:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010454f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80104552:	e8 f1 10 00 00       	call   80105648 <popcli>
  return p;
80104557:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010455a:	c9                   	leave  
8010455b:	c3                   	ret    

8010455c <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010455c:	55                   	push   %ebp
8010455d:	89 e5                	mov    %esp,%ebp
8010455f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104562:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104569:	e8 31 0f 00 00       	call   8010549f <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010456e:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104575:	eb 53                	jmp    801045ca <allocproc+0x6e>
    if(p->state == UNUSED)
80104577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457a:	8b 40 0c             	mov    0xc(%eax),%eax
8010457d:	85 c0                	test   %eax,%eax
8010457f:	75 42                	jne    801045c3 <allocproc+0x67>
      goto found;
80104581:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104585:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010458c:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104591:	8d 50 01             	lea    0x1(%eax),%edx
80104594:	89 15 00 d0 10 80    	mov    %edx,0x8010d000
8010459a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010459d:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
801045a0:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801045a7:	e8 5d 0f 00 00       	call   80105509 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801045ac:	e8 db e8 ff ff       	call   80102e8c <kalloc>
801045b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b4:	89 42 08             	mov    %eax,0x8(%edx)
801045b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ba:	8b 40 08             	mov    0x8(%eax),%eax
801045bd:	85 c0                	test   %eax,%eax
801045bf:	75 39                	jne    801045fa <allocproc+0x9e>
801045c1:	eb 26                	jmp    801045e9 <allocproc+0x8d>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801045c3:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801045ca:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
801045d1:	72 a4                	jb     80104577 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801045d3:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801045da:	e8 2a 0f 00 00       	call   80105509 <release>
  return 0;
801045df:	b8 00 00 00 00       	mov    $0x0,%eax
801045e4:	e9 8d 00 00 00       	jmp    80104676 <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801045e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045ec:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801045f3:	b8 00 00 00 00       	mov    $0x0,%eax
801045f8:	eb 7c                	jmp    80104676 <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
801045fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fd:	8b 40 08             	mov    0x8(%eax),%eax
80104600:	05 00 10 00 00       	add    $0x1000,%eax
80104605:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104608:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
8010460c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010460f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104612:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104615:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104619:	ba 50 72 10 80       	mov    $0x80107250,%edx
8010461e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104621:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104623:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010462a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010462d:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104633:	8b 40 1c             	mov    0x1c(%eax),%eax
80104636:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010463d:	00 
8010463e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104645:	00 
80104646:	89 04 24             	mov    %eax,(%esp)
80104649:	e8 b4 10 00 00       	call   80105702 <memset>
  p->context->eip = (uint)forkret;
8010464e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104651:	8b 40 1c             	mov    0x1c(%eax),%eax
80104654:	ba a5 4d 10 80       	mov    $0x80104da5,%edx
80104659:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
8010465c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465f:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
80104666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104669:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104670:	00 00 00 
  // }
  //SUCC
  // if(p->cont == NULL)
  //   cprintf("p container is now null.\n");

  return p;
80104673:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104676:	c9                   	leave  
80104677:	c3                   	ret    

80104678 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104678:	55                   	push   %ebp
80104679:	89 e5                	mov    %esp,%ebp
8010467b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
8010467e:	e8 d9 fe ff ff       	call   8010455c <allocproc>
80104683:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104689:	a3 20 d9 10 80       	mov    %eax,0x8010d920
  if((p->pgdir = setupkvm()) == 0)
8010468e:	e8 17 41 00 00       	call   801087aa <setupkvm>
80104693:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104696:	89 42 04             	mov    %eax,0x4(%edx)
80104699:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010469c:	8b 40 04             	mov    0x4(%eax),%eax
8010469f:	85 c0                	test   %eax,%eax
801046a1:	75 0c                	jne    801046af <userinit+0x37>
    panic("userinit: out of memory?");
801046a3:	c7 04 24 ce 9c 10 80 	movl   $0x80109cce,(%esp)
801046aa:	e8 a5 be ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801046af:	ba 2c 00 00 00       	mov    $0x2c,%edx
801046b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b7:	8b 40 04             	mov    0x4(%eax),%eax
801046ba:	89 54 24 08          	mov    %edx,0x8(%esp)
801046be:	c7 44 24 04 60 d5 10 	movl   $0x8010d560,0x4(%esp)
801046c5:	80 
801046c6:	89 04 24             	mov    %eax,(%esp)
801046c9:	e8 3d 43 00 00       	call   80108a0b <inituvm>
  p->sz = PGSIZE;
801046ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801046d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046da:	8b 40 18             	mov    0x18(%eax),%eax
801046dd:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801046e4:	00 
801046e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801046ec:	00 
801046ed:	89 04 24             	mov    %eax,(%esp)
801046f0:	e8 0d 10 00 00       	call   80105702 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801046f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f8:	8b 40 18             	mov    0x18(%eax),%eax
801046fb:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104701:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104704:	8b 40 18             	mov    0x18(%eax),%eax
80104707:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010470d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104710:	8b 50 18             	mov    0x18(%eax),%edx
80104713:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104716:	8b 40 18             	mov    0x18(%eax),%eax
80104719:	8b 40 2c             	mov    0x2c(%eax),%eax
8010471c:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104720:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104723:	8b 50 18             	mov    0x18(%eax),%edx
80104726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104729:	8b 40 18             	mov    0x18(%eax),%eax
8010472c:	8b 40 2c             	mov    0x2c(%eax),%eax
8010472f:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
80104733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104736:	8b 40 18             	mov    0x18(%eax),%eax
80104739:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104743:	8b 40 18             	mov    0x18(%eax),%eax
80104746:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010474d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104750:	8b 40 18             	mov    0x18(%eax),%eax
80104753:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010475a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475d:	83 c0 6c             	add    $0x6c,%eax
80104760:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104767:	00 
80104768:	c7 44 24 04 e7 9c 10 	movl   $0x80109ce7,0x4(%esp)
8010476f:	80 
80104770:	89 04 24             	mov    %eax,(%esp)
80104773:	e8 96 11 00 00       	call   8010590e <safestrcpy>
  p->cwd = namei("/");
80104778:	c7 04 24 f0 9c 10 80 	movl   $0x80109cf0,(%esp)
8010477f:	e8 a9 df ff ff       	call   8010272d <namei>
80104784:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104787:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010478a:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104791:	e8 09 0d 00 00       	call   8010549f <acquire>

  p->state = RUNNABLE;
80104796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104799:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801047a0:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801047a7:	e8 5d 0d 00 00       	call   80105509 <release>
}
801047ac:	c9                   	leave  
801047ad:	c3                   	ret    

801047ae <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801047ae:	55                   	push   %ebp
801047af:	89 e5                	mov    %esp,%ebp
801047b1:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801047b4:	e8 7a fd ff ff       	call   80104533 <myproc>
801047b9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801047bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047bf:	8b 00                	mov    (%eax),%eax
801047c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801047c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047c8:	7e 31                	jle    801047fb <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801047ca:	8b 55 08             	mov    0x8(%ebp),%edx
801047cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d0:	01 c2                	add    %eax,%edx
801047d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801047d5:	8b 40 04             	mov    0x4(%eax),%eax
801047d8:	89 54 24 08          	mov    %edx,0x8(%esp)
801047dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801047df:	89 54 24 04          	mov    %edx,0x4(%esp)
801047e3:	89 04 24             	mov    %eax,(%esp)
801047e6:	e8 8b 43 00 00       	call   80108b76 <allocuvm>
801047eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801047f2:	75 3e                	jne    80104832 <growproc+0x84>
      return -1;
801047f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f9:	eb 4f                	jmp    8010484a <growproc+0x9c>
  } else if(n < 0){
801047fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801047ff:	79 31                	jns    80104832 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104801:	8b 55 08             	mov    0x8(%ebp),%edx
80104804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104807:	01 c2                	add    %eax,%edx
80104809:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010480c:	8b 40 04             	mov    0x4(%eax),%eax
8010480f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104813:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104816:	89 54 24 04          	mov    %edx,0x4(%esp)
8010481a:	89 04 24             	mov    %eax,(%esp)
8010481d:	e8 6a 44 00 00       	call   80108c8c <deallocuvm>
80104822:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104825:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104829:	75 07                	jne    80104832 <growproc+0x84>
      return -1;
8010482b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104830:	eb 18                	jmp    8010484a <growproc+0x9c>
  }
  curproc->sz = sz;
80104832:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104835:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104838:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010483a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010483d:	89 04 24             	mov    %eax,(%esp)
80104840:	e8 3f 40 00 00       	call   80108884 <switchuvm>
  return 0;
80104845:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010484a:	c9                   	leave  
8010484b:	c3                   	ret    

8010484c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010484c:	55                   	push   %ebp
8010484d:	89 e5                	mov    %esp,%ebp
8010484f:	57                   	push   %edi
80104850:	56                   	push   %esi
80104851:	53                   	push   %ebx
80104852:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104855:	e8 d9 fc ff ff       	call   80104533 <myproc>
8010485a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010485d:	e8 fa fc ff ff       	call   8010455c <allocproc>
80104862:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104865:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104869:	75 0a                	jne    80104875 <fork+0x29>
    return -1;
8010486b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104870:	e9 47 01 00 00       	jmp    801049bc <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104875:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104878:	8b 10                	mov    (%eax),%edx
8010487a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010487d:	8b 40 04             	mov    0x4(%eax),%eax
80104880:	89 54 24 04          	mov    %edx,0x4(%esp)
80104884:	89 04 24             	mov    %eax,(%esp)
80104887:	e8 a0 45 00 00       	call   80108e2c <copyuvm>
8010488c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010488f:	89 42 04             	mov    %eax,0x4(%edx)
80104892:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104895:	8b 40 04             	mov    0x4(%eax),%eax
80104898:	85 c0                	test   %eax,%eax
8010489a:	75 2c                	jne    801048c8 <fork+0x7c>
    kfree(np->kstack);
8010489c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010489f:	8b 40 08             	mov    0x8(%eax),%eax
801048a2:	89 04 24             	mov    %eax,(%esp)
801048a5:	e8 05 e5 ff ff       	call   80102daf <kfree>
    np->kstack = 0;
801048aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801048b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048b7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801048be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c3:	e9 f4 00 00 00       	jmp    801049bc <fork+0x170>
  }
  np->sz = curproc->sz;
801048c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048cb:	8b 10                	mov    (%eax),%edx
801048cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d0:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801048d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048d8:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801048db:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048de:	8b 50 18             	mov    0x18(%eax),%edx
801048e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048e4:	8b 40 18             	mov    0x18(%eax),%eax
801048e7:	89 c3                	mov    %eax,%ebx
801048e9:	b8 13 00 00 00       	mov    $0x13,%eax
801048ee:	89 d7                	mov    %edx,%edi
801048f0:	89 de                	mov    %ebx,%esi
801048f2:	89 c1                	mov    %eax,%ecx
801048f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801048f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801048f9:	8b 40 18             	mov    0x18(%eax),%eax
801048fc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104903:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010490a:	eb 36                	jmp    80104942 <fork+0xf6>
    if(curproc->ofile[i])
8010490c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010490f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104912:	83 c2 08             	add    $0x8,%edx
80104915:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104919:	85 c0                	test   %eax,%eax
8010491b:	74 22                	je     8010493f <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010491d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104920:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104923:	83 c2 08             	add    $0x8,%edx
80104926:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010492a:	89 04 24             	mov    %eax,(%esp)
8010492d:	e8 30 c8 ff ff       	call   80101162 <filedup>
80104932:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104935:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104938:	83 c1 08             	add    $0x8,%ecx
8010493b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010493f:	ff 45 e4             	incl   -0x1c(%ebp)
80104942:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104946:	7e c4                	jle    8010490c <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104948:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494b:	8b 40 68             	mov    0x68(%eax),%eax
8010494e:	89 04 24             	mov    %eax,(%esp)
80104951:	e8 3a d1 ff ff       	call   80101a90 <idup>
80104956:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104959:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010495c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010495f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104962:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104965:	83 c0 6c             	add    $0x6c,%eax
80104968:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010496f:	00 
80104970:	89 54 24 04          	mov    %edx,0x4(%esp)
80104974:	89 04 24             	mov    %eax,(%esp)
80104977:	e8 92 0f 00 00       	call   8010590e <safestrcpy>



  pid = np->pid;
8010497c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010497f:	8b 40 10             	mov    0x10(%eax),%eax
80104982:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104985:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
8010498c:	e8 0e 0b 00 00       	call   8010549f <acquire>

  np->state = RUNNABLE;
80104991:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104994:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
8010499b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010499e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
801049a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049a7:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
801049ad:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
801049b4:	e8 50 0b 00 00       	call   80105509 <release>

  return pid;
801049b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801049bc:	83 c4 2c             	add    $0x2c,%esp
801049bf:	5b                   	pop    %ebx
801049c0:	5e                   	pop    %esi
801049c1:	5f                   	pop    %edi
801049c2:	5d                   	pop    %ebp
801049c3:	c3                   	ret    

801049c4 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801049c4:	55                   	push   %ebp
801049c5:	89 e5                	mov    %esp,%ebp
801049c7:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801049ca:	e8 64 fb ff ff       	call   80104533 <myproc>
801049cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801049d2:	a1 20 d9 10 80       	mov    0x8010d920,%eax
801049d7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801049da:	75 0c                	jne    801049e8 <exit+0x24>
    panic("init exiting");
801049dc:	c7 04 24 f2 9c 10 80 	movl   $0x80109cf2,(%esp)
801049e3:	e8 6c bb ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049e8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049ef:	eb 3a                	jmp    80104a2b <exit+0x67>
    if(curproc->ofile[fd]){
801049f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049f7:	83 c2 08             	add    $0x8,%edx
801049fa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049fe:	85 c0                	test   %eax,%eax
80104a00:	74 26                	je     80104a28 <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104a02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a05:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a08:	83 c2 08             	add    $0x8,%edx
80104a0b:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a0f:	89 04 24             	mov    %eax,(%esp)
80104a12:	e8 93 c7 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a1d:	83 c2 08             	add    $0x8,%edx
80104a20:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a27:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a28:	ff 45 f0             	incl   -0x10(%ebp)
80104a2b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a2f:	7e c0                	jle    801049f1 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104a31:	e8 d5 ed ff ff       	call   8010380b <begin_op>
  iput(curproc->cwd);
80104a36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a39:	8b 40 68             	mov    0x68(%eax),%eax
80104a3c:	89 04 24             	mov    %eax,(%esp)
80104a3f:	e8 cc d1 ff ff       	call   80101c10 <iput>
  end_op();
80104a44:	e8 44 ee ff ff       	call   8010388d <end_op>
  curproc->cwd = 0;
80104a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a4c:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a53:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104a5a:	e8 40 0a 00 00       	call   8010549f <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104a5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a62:	8b 40 14             	mov    0x14(%eax),%eax
80104a65:	89 04 24             	mov    %eax,(%esp)
80104a68:	e8 0d 04 00 00       	call   80104e7a <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a6d:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104a74:	eb 36                	jmp    80104aac <exit+0xe8>
    if(p->parent == curproc){
80104a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a79:	8b 40 14             	mov    0x14(%eax),%eax
80104a7c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104a7f:	75 24                	jne    80104aa5 <exit+0xe1>
      p->parent = initproc;
80104a81:	8b 15 20 d9 10 80    	mov    0x8010d920,%edx
80104a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8a:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a90:	8b 40 0c             	mov    0xc(%eax),%eax
80104a93:	83 f8 05             	cmp    $0x5,%eax
80104a96:	75 0d                	jne    80104aa5 <exit+0xe1>
        wakeup1(initproc);
80104a98:	a1 20 d9 10 80       	mov    0x8010d920,%eax
80104a9d:	89 04 24             	mov    %eax,(%esp)
80104aa0:	e8 d5 03 00 00       	call   80104e7a <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aa5:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104aac:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80104ab3:	72 c1                	jb     80104a76 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104ab5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ab8:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104abf:	e8 01 02 00 00       	call   80104cc5 <sched>
  panic("zombie exit");
80104ac4:	c7 04 24 ff 9c 10 80 	movl   $0x80109cff,(%esp)
80104acb:	e8 84 ba ff ff       	call   80100554 <panic>

80104ad0 <strcmp1>:
}


int
strcmp1(const char *p, const char *q)
{
80104ad0:	55                   	push   %ebp
80104ad1:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104ad3:	eb 06                	jmp    80104adb <strcmp1+0xb>
    p++, q++;
80104ad5:	ff 45 08             	incl   0x8(%ebp)
80104ad8:	ff 45 0c             	incl   0xc(%ebp)


int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104adb:	8b 45 08             	mov    0x8(%ebp),%eax
80104ade:	8a 00                	mov    (%eax),%al
80104ae0:	84 c0                	test   %al,%al
80104ae2:	74 0e                	je     80104af2 <strcmp1+0x22>
80104ae4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ae7:	8a 10                	mov    (%eax),%dl
80104ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aec:	8a 00                	mov    (%eax),%al
80104aee:	38 c2                	cmp    %al,%dl
80104af0:	74 e3                	je     80104ad5 <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104af2:	8b 45 08             	mov    0x8(%ebp),%eax
80104af5:	8a 00                	mov    (%eax),%al
80104af7:	0f b6 d0             	movzbl %al,%edx
80104afa:	8b 45 0c             	mov    0xc(%ebp),%eax
80104afd:	8a 00                	mov    (%eax),%al
80104aff:	0f b6 c0             	movzbl %al,%eax
80104b02:	29 c2                	sub    %eax,%edx
80104b04:	89 d0                	mov    %edx,%eax
}
80104b06:	5d                   	pop    %ebp
80104b07:	c3                   	ret    

80104b08 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104b08:	55                   	push   %ebp
80104b09:	89 e5                	mov    %esp,%ebp
80104b0b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104b0e:	e8 20 fa ff ff       	call   80104533 <myproc>
80104b13:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104b16:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104b1d:	e8 7d 09 00 00       	call   8010549f <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104b22:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b29:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104b30:	e9 98 00 00 00       	jmp    80104bcd <wait+0xc5>
      if(p->parent != curproc)
80104b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b38:	8b 40 14             	mov    0x14(%eax),%eax
80104b3b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104b3e:	74 05                	je     80104b45 <wait+0x3d>
        continue;
80104b40:	e9 81 00 00 00       	jmp    80104bc6 <wait+0xbe>
      havekids = 1;
80104b45:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b52:	83 f8 05             	cmp    $0x5,%eax
80104b55:	75 6f                	jne    80104bc6 <wait+0xbe>
        // Found one.
        pid = p->pid;
80104b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5a:	8b 40 10             	mov    0x10(%eax),%eax
80104b5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104b60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b63:	8b 40 08             	mov    0x8(%eax),%eax
80104b66:	89 04 24             	mov    %eax,(%esp)
80104b69:	e8 41 e2 ff ff       	call   80102daf <kfree>
        p->kstack = 0;
80104b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b71:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7b:	8b 40 04             	mov    0x4(%eax),%eax
80104b7e:	89 04 24             	mov    %eax,(%esp)
80104b81:	e8 ca 41 00 00       	call   80108d50 <freevm>
        p->pid = 0;
80104b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b89:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b93:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b9d:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba4:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bae:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104bb5:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104bbc:	e8 48 09 00 00       	call   80105509 <release>
        return pid;
80104bc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104bc4:	eb 4f                	jmp    80104c15 <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bc6:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104bcd:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80104bd4:	0f 82 5b ff ff ff    	jb     80104b35 <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104bda:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bde:	74 0a                	je     80104bea <wait+0xe2>
80104be0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104be3:	8b 40 24             	mov    0x24(%eax),%eax
80104be6:	85 c0                	test   %eax,%eax
80104be8:	74 13                	je     80104bfd <wait+0xf5>
      release(&ptable.lock);
80104bea:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104bf1:	e8 13 09 00 00       	call   80105509 <release>
      return -1;
80104bf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bfb:	eb 18                	jmp    80104c15 <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104bfd:	c7 44 24 04 60 62 11 	movl   $0x80116260,0x4(%esp)
80104c04:	80 
80104c05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c08:	89 04 24             	mov    %eax,(%esp)
80104c0b:	e8 d4 01 00 00       	call   80104de4 <sleep>
  }
80104c10:	e9 0d ff ff ff       	jmp    80104b22 <wait+0x1a>
}
80104c15:	c9                   	leave  
80104c16:	c3                   	ret    

80104c17 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104c17:	55                   	push   %ebp
80104c18:	89 e5                	mov    %esp,%ebp
80104c1a:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104c1d:	e8 8d f8 ff ff       	call   801044af <mycpu>
80104c22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c28:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104c2f:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c32:	e8 11 f8 ff ff       	call   80104448 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c37:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104c3e:	e8 5c 08 00 00       	call   8010549f <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c43:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104c4a:	eb 5f                	jmp    80104cab <scheduler+0x94>
      if(p->state != RUNNABLE)
80104c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c4f:	8b 40 0c             	mov    0xc(%eax),%eax
80104c52:	83 f8 03             	cmp    $0x3,%eax
80104c55:	74 02                	je     80104c59 <scheduler+0x42>
        continue;
80104c57:	eb 4b                	jmp    80104ca4 <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104c59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c5f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c68:	89 04 24             	mov    %eax,(%esp)
80104c6b:	e8 14 3c 00 00       	call   80108884 <switchuvm>
      p->state = RUNNING;
80104c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c73:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c7d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c80:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104c83:	83 c2 04             	add    $0x4,%edx
80104c86:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c8a:	89 14 24             	mov    %edx,(%esp)
80104c8d:	e8 ea 0c 00 00       	call   8010597c <swtch>
      switchkvm();
80104c92:	e8 d3 3b 00 00       	call   8010886a <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104c97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c9a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104ca1:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ca4:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104cab:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80104cb2:	72 98                	jb     80104c4c <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104cb4:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104cbb:	e8 49 08 00 00       	call   80105509 <release>

  }
80104cc0:	e9 6d ff ff ff       	jmp    80104c32 <scheduler+0x1b>

80104cc5 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104cc5:	55                   	push   %ebp
80104cc6:	89 e5                	mov    %esp,%ebp
80104cc8:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104ccb:	e8 63 f8 ff ff       	call   80104533 <myproc>
80104cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104cd3:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104cda:	e8 ee 08 00 00       	call   801055cd <holding>
80104cdf:	85 c0                	test   %eax,%eax
80104ce1:	75 0c                	jne    80104cef <sched+0x2a>
    panic("sched ptable.lock");
80104ce3:	c7 04 24 0b 9d 10 80 	movl   $0x80109d0b,(%esp)
80104cea:	e8 65 b8 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104cef:	e8 bb f7 ff ff       	call   801044af <mycpu>
80104cf4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104cfa:	83 f8 01             	cmp    $0x1,%eax
80104cfd:	74 0c                	je     80104d0b <sched+0x46>
    panic("sched locks");
80104cff:	c7 04 24 1d 9d 10 80 	movl   $0x80109d1d,(%esp)
80104d06:	e8 49 b8 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d0e:	8b 40 0c             	mov    0xc(%eax),%eax
80104d11:	83 f8 04             	cmp    $0x4,%eax
80104d14:	75 0c                	jne    80104d22 <sched+0x5d>
    panic("sched running");
80104d16:	c7 04 24 29 9d 10 80 	movl   $0x80109d29,(%esp)
80104d1d:	e8 32 b8 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104d22:	e8 11 f7 ff ff       	call   80104438 <readeflags>
80104d27:	25 00 02 00 00       	and    $0x200,%eax
80104d2c:	85 c0                	test   %eax,%eax
80104d2e:	74 0c                	je     80104d3c <sched+0x77>
    panic("sched interruptible");
80104d30:	c7 04 24 37 9d 10 80 	movl   $0x80109d37,(%esp)
80104d37:	e8 18 b8 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104d3c:	e8 6e f7 ff ff       	call   801044af <mycpu>
80104d41:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104d47:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104d4a:	e8 60 f7 ff ff       	call   801044af <mycpu>
80104d4f:	8b 40 04             	mov    0x4(%eax),%eax
80104d52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d55:	83 c2 1c             	add    $0x1c,%edx
80104d58:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d5c:	89 14 24             	mov    %edx,(%esp)
80104d5f:	e8 18 0c 00 00       	call   8010597c <swtch>
  mycpu()->intena = intena;
80104d64:	e8 46 f7 ff ff       	call   801044af <mycpu>
80104d69:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d6c:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104d72:	c9                   	leave  
80104d73:	c3                   	ret    

80104d74 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d74:	55                   	push   %ebp
80104d75:	89 e5                	mov    %esp,%ebp
80104d77:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d7a:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104d81:	e8 19 07 00 00       	call   8010549f <acquire>
  myproc()->state = RUNNABLE;
80104d86:	e8 a8 f7 ff ff       	call   80104533 <myproc>
80104d8b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d92:	e8 2e ff ff ff       	call   80104cc5 <sched>
  release(&ptable.lock);
80104d97:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104d9e:	e8 66 07 00 00       	call   80105509 <release>
}
80104da3:	c9                   	leave  
80104da4:	c3                   	ret    

80104da5 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104da5:	55                   	push   %ebp
80104da6:	89 e5                	mov    %esp,%ebp
80104da8:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104dab:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104db2:	e8 52 07 00 00       	call   80105509 <release>

  if (first) {
80104db7:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104dbc:	85 c0                	test   %eax,%eax
80104dbe:	74 22                	je     80104de2 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104dc0:	c7 05 04 d0 10 80 00 	movl   $0x0,0x8010d004
80104dc7:	00 00 00 
    iinit(ROOTDEV);
80104dca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104dd1:	e8 85 c9 ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104dd6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ddd:	e8 2a e8 ff ff       	call   8010360c <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104de2:	c9                   	leave  
80104de3:	c3                   	ret    

80104de4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104de4:	55                   	push   %ebp
80104de5:	89 e5                	mov    %esp,%ebp
80104de7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104dea:	e8 44 f7 ff ff       	call   80104533 <myproc>
80104def:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104df2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104df6:	75 0c                	jne    80104e04 <sleep+0x20>
    panic("sleep");
80104df8:	c7 04 24 4b 9d 10 80 	movl   $0x80109d4b,(%esp)
80104dff:	e8 50 b7 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104e04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e08:	75 0c                	jne    80104e16 <sleep+0x32>
    panic("sleep without lk");
80104e0a:	c7 04 24 51 9d 10 80 	movl   $0x80109d51,(%esp)
80104e11:	e8 3e b7 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e16:	81 7d 0c 60 62 11 80 	cmpl   $0x80116260,0xc(%ebp)
80104e1d:	74 17                	je     80104e36 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e1f:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104e26:	e8 74 06 00 00       	call   8010549f <acquire>
    release(lk);
80104e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e2e:	89 04 24             	mov    %eax,(%esp)
80104e31:	e8 d3 06 00 00       	call   80105509 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e39:	8b 55 08             	mov    0x8(%ebp),%edx
80104e3c:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e42:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104e49:	e8 77 fe ff ff       	call   80104cc5 <sched>

  // Tidy up.
  p->chan = 0;
80104e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e51:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e58:	81 7d 0c 60 62 11 80 	cmpl   $0x80116260,0xc(%ebp)
80104e5f:	74 17                	je     80104e78 <sleep+0x94>
    release(&ptable.lock);
80104e61:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104e68:	e8 9c 06 00 00       	call   80105509 <release>
    acquire(lk);
80104e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e70:	89 04 24             	mov    %eax,(%esp)
80104e73:	e8 27 06 00 00       	call   8010549f <acquire>
  }
}
80104e78:	c9                   	leave  
80104e79:	c3                   	ret    

80104e7a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e7a:	55                   	push   %ebp
80104e7b:	89 e5                	mov    %esp,%ebp
80104e7d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e80:	c7 45 fc 94 62 11 80 	movl   $0x80116294,-0x4(%ebp)
80104e87:	eb 27                	jmp    80104eb0 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104e89:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e8c:	8b 40 0c             	mov    0xc(%eax),%eax
80104e8f:	83 f8 02             	cmp    $0x2,%eax
80104e92:	75 15                	jne    80104ea9 <wakeup1+0x2f>
80104e94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e97:	8b 40 20             	mov    0x20(%eax),%eax
80104e9a:	3b 45 08             	cmp    0x8(%ebp),%eax
80104e9d:	75 0a                	jne    80104ea9 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ea2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ea9:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104eb0:	81 7d fc 94 83 11 80 	cmpl   $0x80118394,-0x4(%ebp)
80104eb7:	72 d0                	jb     80104e89 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104eb9:	c9                   	leave  
80104eba:	c3                   	ret    

80104ebb <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ebb:	55                   	push   %ebp
80104ebc:	89 e5                	mov    %esp,%ebp
80104ebe:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104ec1:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104ec8:	e8 d2 05 00 00       	call   8010549f <acquire>
  wakeup1(chan);
80104ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ed0:	89 04 24             	mov    %eax,(%esp)
80104ed3:	e8 a2 ff ff ff       	call   80104e7a <wakeup1>
  release(&ptable.lock);
80104ed8:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104edf:	e8 25 06 00 00       	call   80105509 <release>
}
80104ee4:	c9                   	leave  
80104ee5:	c3                   	ret    

80104ee6 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ee6:	55                   	push   %ebp
80104ee7:	89 e5                	mov    %esp,%ebp
80104ee9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104eec:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104ef3:	e8 a7 05 00 00       	call   8010549f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ef8:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80104eff:	eb 44                	jmp    80104f45 <kill+0x5f>
    if(p->pid == pid){
80104f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f04:	8b 40 10             	mov    0x10(%eax),%eax
80104f07:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f0a:	75 32                	jne    80104f3e <kill+0x58>
      p->killed = 1;
80104f0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f0f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f19:	8b 40 0c             	mov    0xc(%eax),%eax
80104f1c:	83 f8 02             	cmp    $0x2,%eax
80104f1f:	75 0a                	jne    80104f2b <kill+0x45>
        p->state = RUNNABLE;
80104f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f24:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104f2b:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f32:	e8 d2 05 00 00       	call   80105509 <release>
      return 0;
80104f37:	b8 00 00 00 00       	mov    $0x0,%eax
80104f3c:	eb 21                	jmp    80104f5f <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f3e:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104f45:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80104f4c:	72 b3                	jb     80104f01 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104f4e:	c7 04 24 60 62 11 80 	movl   $0x80116260,(%esp)
80104f55:	e8 af 05 00 00       	call   80105509 <release>
  return -1;
80104f5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f5f:	c9                   	leave  
80104f60:	c3                   	ret    

80104f61 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f61:	55                   	push   %ebp
80104f62:	89 e5                	mov    %esp,%ebp
80104f64:	83 ec 68             	sub    $0x68,%esp
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f67:	c7 45 f0 94 62 11 80 	movl   $0x80116294,-0x10(%ebp)
80104f6e:	e9 1e 01 00 00       	jmp    80105091 <procdump+0x130>
    if(p->state == UNUSED)
80104f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f76:	8b 40 0c             	mov    0xc(%eax),%eax
80104f79:	85 c0                	test   %eax,%eax
80104f7b:	75 05                	jne    80104f82 <procdump+0x21>
      continue;
80104f7d:	e9 08 01 00 00       	jmp    8010508a <procdump+0x129>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f85:	8b 40 0c             	mov    0xc(%eax),%eax
80104f88:	83 f8 05             	cmp    $0x5,%eax
80104f8b:	77 23                	ja     80104fb0 <procdump+0x4f>
80104f8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f90:	8b 40 0c             	mov    0xc(%eax),%eax
80104f93:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80104f9a:	85 c0                	test   %eax,%eax
80104f9c:	74 12                	je     80104fb0 <procdump+0x4f>
      state = states[p->state];
80104f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fa1:	8b 40 0c             	mov    0xc(%eax),%eax
80104fa4:	8b 04 85 08 d0 10 80 	mov    -0x7fef2ff8(,%eax,4),%eax
80104fab:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104fae:	eb 07                	jmp    80104fb7 <procdump+0x56>
    else
      state = "???";
80104fb0:	c7 45 ec 62 9d 10 80 	movl   $0x80109d62,-0x14(%ebp)

    if(p->cont == NULL){
80104fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fba:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104fc0:	85 c0                	test   %eax,%eax
80104fc2:	75 29                	jne    80104fed <procdump+0x8c>
      cprintf("%d root %s %s", p->pid, state, p->name);
80104fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc7:	8d 50 6c             	lea    0x6c(%eax),%edx
80104fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fcd:	8b 40 10             	mov    0x10(%eax),%eax
80104fd0:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104fd4:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fd7:	89 54 24 08          	mov    %edx,0x8(%esp)
80104fdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fdf:	c7 04 24 66 9d 10 80 	movl   $0x80109d66,(%esp)
80104fe6:	e8 d6 b3 ff ff       	call   801003c1 <cprintf>
80104feb:	eb 37                	jmp    80105024 <procdump+0xc3>
    }
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
80104fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff0:	8d 50 6c             	lea    0x6c(%eax),%edx
80104ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ff6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104ffc:	8d 48 18             	lea    0x18(%eax),%ecx
80104fff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105002:	8b 40 10             	mov    0x10(%eax),%eax
80105005:	89 54 24 10          	mov    %edx,0x10(%esp)
80105009:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010500c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105010:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105014:	89 44 24 04          	mov    %eax,0x4(%esp)
80105018:	c7 04 24 74 9d 10 80 	movl   $0x80109d74,(%esp)
8010501f:	e8 9d b3 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
80105024:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105027:	8b 40 0c             	mov    0xc(%eax),%eax
8010502a:	83 f8 02             	cmp    $0x2,%eax
8010502d:	75 4f                	jne    8010507e <procdump+0x11d>
      getcallerpcs((uint*)p->context->ebp+2, pc);
8010502f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105032:	8b 40 1c             	mov    0x1c(%eax),%eax
80105035:	8b 40 0c             	mov    0xc(%eax),%eax
80105038:	83 c0 08             	add    $0x8,%eax
8010503b:	8d 55 c4             	lea    -0x3c(%ebp),%edx
8010503e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105042:	89 04 24             	mov    %eax,(%esp)
80105045:	e8 0c 05 00 00       	call   80105556 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010504a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105051:	eb 1a                	jmp    8010506d <procdump+0x10c>
        cprintf(" %p", pc[i]);
80105053:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105056:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010505a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010505e:	c7 04 24 80 9d 10 80 	movl   $0x80109d80,(%esp)
80105065:	e8 57 b3 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s", p->pid, p->cont->name, state, p->name);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010506a:	ff 45 f4             	incl   -0xc(%ebp)
8010506d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105071:	7f 0b                	jg     8010507e <procdump+0x11d>
80105073:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105076:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010507a:	85 c0                	test   %eax,%eax
8010507c:	75 d5                	jne    80105053 <procdump+0xf2>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010507e:	c7 04 24 84 9d 10 80 	movl   $0x80109d84,(%esp)
80105085:	e8 37 b3 ff ff       	call   801003c1 <cprintf>
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010508a:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80105091:	81 7d f0 94 83 11 80 	cmpl   $0x80118394,-0x10(%ebp)
80105098:	0f 82 d5 fe ff ff    	jb     80104f73 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010509e:	c9                   	leave  
8010509f:	c3                   	ret    

801050a0 <cstop_container_helper>:


void cstop_container_helper(struct container* cont){
801050a0:	55                   	push   %ebp
801050a1:	89 e5                	mov    %esp,%ebp
801050a3:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050a6:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
801050ad:	eb 37                	jmp    801050e6 <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
801050af:	8b 45 08             	mov    0x8(%ebp),%eax
801050b2:	8d 50 18             	lea    0x18(%eax),%edx
801050b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801050be:	83 c0 18             	add    $0x18,%eax
801050c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801050c5:	89 04 24             	mov    %eax,(%esp)
801050c8:	e8 03 fa ff ff       	call   80104ad0 <strcmp1>
801050cd:	85 c0                	test   %eax,%eax
801050cf:	75 0e                	jne    801050df <cstop_container_helper+0x3f>
      kill(p->pid);
801050d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d4:	8b 40 10             	mov    0x10(%eax),%eax
801050d7:	89 04 24             	mov    %eax,(%esp)
801050da:	e8 07 fe ff ff       	call   80104ee6 <kill>


void cstop_container_helper(struct container* cont){

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050df:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801050e6:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
801050ed:	72 c0                	jb     801050af <cstop_container_helper+0xf>
    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }

  container_reset(find(cont->name));
801050ef:	8b 45 08             	mov    0x8(%ebp),%eax
801050f2:	83 c0 18             	add    $0x18,%eax
801050f5:	89 04 24             	mov    %eax,(%esp)
801050f8:	e8 e6 40 00 00       	call   801091e3 <find>
801050fd:	89 04 24             	mov    %eax,(%esp)
80105100:	e8 d0 46 00 00       	call   801097d5 <container_reset>
}
80105105:	c9                   	leave  
80105106:	c3                   	ret    

80105107 <cstop_helper>:

void cstop_helper(char* name){
80105107:	55                   	push   %ebp
80105108:	89 e5                	mov    %esp,%ebp
8010510a:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010510d:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
80105114:	eb 69                	jmp    8010517f <cstop_helper+0x78>

    if(p->cont == NULL){
80105116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105119:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010511f:	85 c0                	test   %eax,%eax
80105121:	75 02                	jne    80105125 <cstop_helper+0x1e>
      continue;
80105123:	eb 53                	jmp    80105178 <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
80105125:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105128:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010512e:	8d 50 18             	lea    0x18(%eax),%edx
80105131:	8b 45 08             	mov    0x8(%ebp),%eax
80105134:	89 44 24 04          	mov    %eax,0x4(%esp)
80105138:	89 14 24             	mov    %edx,(%esp)
8010513b:	e8 90 f9 ff ff       	call   80104ad0 <strcmp1>
80105140:	85 c0                	test   %eax,%eax
80105142:	75 34                	jne    80105178 <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
80105144:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105147:	8b 40 10             	mov    0x10(%eax),%eax
8010514a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010514d:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
80105153:	83 c2 18             	add    $0x18,%edx
80105156:	89 44 24 08          	mov    %eax,0x8(%esp)
8010515a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010515e:	c7 04 24 88 9d 10 80 	movl   $0x80109d88,(%esp)
80105165:	e8 57 b2 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
8010516a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010516d:	8b 40 10             	mov    0x10(%eax),%eax
80105170:	89 04 24             	mov    %eax,(%esp)
80105173:	e8 6e fd ff ff       	call   80104ee6 <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105178:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010517f:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80105186:	72 8e                	jb     80105116 <cstop_helper+0xf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
      kill(p->pid);
    }
  }
  container_reset(find(name));
80105188:	8b 45 08             	mov    0x8(%ebp),%eax
8010518b:	89 04 24             	mov    %eax,(%esp)
8010518e:	e8 50 40 00 00       	call   801091e3 <find>
80105193:	89 04 24             	mov    %eax,(%esp)
80105196:	e8 3a 46 00 00       	call   801097d5 <container_reset>
}
8010519b:	c9                   	leave  
8010519c:	c3                   	ret    

8010519d <c_procdump>:

void
c_procdump(char* name)
{
8010519d:	55                   	push   %ebp
8010519e:	89 e5                	mov    %esp,%ebp
801051a0:	83 ec 38             	sub    $0x38,%esp
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801051a3:	c7 45 f4 94 62 11 80 	movl   $0x80116294,-0xc(%ebp)
801051aa:	e9 b1 00 00 00       	jmp    80105260 <c_procdump+0xc3>
    if(p->state == UNUSED || p->cont == NULL)
801051af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051b2:	8b 40 0c             	mov    0xc(%eax),%eax
801051b5:	85 c0                	test   %eax,%eax
801051b7:	74 0d                	je     801051c6 <c_procdump+0x29>
801051b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051bc:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801051c2:	85 c0                	test   %eax,%eax
801051c4:	75 05                	jne    801051cb <c_procdump+0x2e>
      continue;
801051c6:	e9 8e 00 00 00       	jmp    80105259 <c_procdump+0xbc>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801051cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ce:	8b 40 0c             	mov    0xc(%eax),%eax
801051d1:	83 f8 05             	cmp    $0x5,%eax
801051d4:	77 23                	ja     801051f9 <c_procdump+0x5c>
801051d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d9:	8b 40 0c             	mov    0xc(%eax),%eax
801051dc:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
801051e3:	85 c0                	test   %eax,%eax
801051e5:	74 12                	je     801051f9 <c_procdump+0x5c>
      state = states[p->state];
801051e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051ea:	8b 40 0c             	mov    0xc(%eax),%eax
801051ed:	8b 04 85 20 d0 10 80 	mov    -0x7fef2fe0(,%eax,4),%eax
801051f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801051f7:	eb 07                	jmp    80105200 <c_procdump+0x63>
    else
      state = "???";
801051f9:	c7 45 f0 62 9d 10 80 	movl   $0x80109d62,-0x10(%ebp)

    if(strcmp1(p->cont->name, name) == 0){
80105200:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105203:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105209:	8d 50 18             	lea    0x18(%eax),%edx
8010520c:	8b 45 08             	mov    0x8(%ebp),%eax
8010520f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105213:	89 14 24             	mov    %edx,(%esp)
80105216:	e8 b5 f8 ff ff       	call   80104ad0 <strcmp1>
8010521b:	85 c0                	test   %eax,%eax
8010521d:	75 3a                	jne    80105259 <c_procdump+0xbc>
      cprintf("     Container: %s Process: %s PID: %d State: %s ", name, p->name, p->pid, state);
8010521f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105222:	8b 40 10             	mov    0x10(%eax),%eax
80105225:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105228:	8d 4a 6c             	lea    0x6c(%edx),%ecx
8010522b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010522e:	89 54 24 10          	mov    %edx,0x10(%esp)
80105232:	89 44 24 0c          	mov    %eax,0xc(%esp)
80105236:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010523a:	8b 45 08             	mov    0x8(%ebp),%eax
8010523d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105241:	c7 04 24 a8 9d 10 80 	movl   $0x80109da8,(%esp)
80105248:	e8 74 b1 ff ff       	call   801003c1 <cprintf>
      // if(p->state == SLEEPING){
      //   getcallerpcs((uint*)p->context->ebp+2, pc);
      //   for(i=0; i<10 && pc[i] != 0; i++)
      //     cprintf(" %p", pc[i]);
      // }
      cprintf("\n");
8010524d:	c7 04 24 84 9d 10 80 	movl   $0x80109d84,(%esp)
80105254:	e8 68 b1 ff ff       	call   801003c1 <cprintf>
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105259:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80105260:	81 7d f4 94 83 11 80 	cmpl   $0x80118394,-0xc(%ebp)
80105267:	0f 82 42 ff ff ff    	jb     801051af <c_procdump+0x12>
      //     cprintf(" %p", pc[i]);
      // }
      cprintf("\n");
    }  
  }
}
8010526d:	c9                   	leave  
8010526e:	c3                   	ret    

8010526f <pause>:

void
pause(char* name)
{
8010526f:	55                   	push   %ebp
80105270:	89 e5                	mov    %esp,%ebp
80105272:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105275:	c7 45 fc 94 62 11 80 	movl   $0x80116294,-0x4(%ebp)
8010527c:	eb 49                	jmp    801052c7 <pause+0x58>
    if(p->state == UNUSED || p->cont == NULL)
8010527e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105281:	8b 40 0c             	mov    0xc(%eax),%eax
80105284:	85 c0                	test   %eax,%eax
80105286:	74 0d                	je     80105295 <pause+0x26>
80105288:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010528b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105291:	85 c0                	test   %eax,%eax
80105293:	75 02                	jne    80105297 <pause+0x28>
      continue;
80105295:	eb 29                	jmp    801052c0 <pause+0x51>
    if(strcmp1(p->cont->name, name) == 0){
80105297:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010529a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052a0:	8d 50 18             	lea    0x18(%eax),%edx
801052a3:	8b 45 08             	mov    0x8(%ebp),%eax
801052a6:	89 44 24 04          	mov    %eax,0x4(%esp)
801052aa:	89 14 24             	mov    %edx,(%esp)
801052ad:	e8 1e f8 ff ff       	call   80104ad0 <strcmp1>
801052b2:	85 c0                	test   %eax,%eax
801052b4:	75 0a                	jne    801052c0 <pause+0x51>
      p->state = ZOMBIE;
801052b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052b9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
void
pause(char* name)
{
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052c0:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
801052c7:	81 7d fc 94 83 11 80 	cmpl   $0x80118394,-0x4(%ebp)
801052ce:	72 ae                	jb     8010527e <pause+0xf>
      continue;
    if(strcmp1(p->cont->name, name) == 0){
      p->state = ZOMBIE;
    }
  }
}
801052d0:	c9                   	leave  
801052d1:	c3                   	ret    

801052d2 <resume>:

void
resume(char* name)
{
801052d2:	55                   	push   %ebp
801052d3:	89 e5                	mov    %esp,%ebp
801052d5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052d8:	c7 45 fc 94 62 11 80 	movl   $0x80116294,-0x4(%ebp)
801052df:	eb 3b                	jmp    8010531c <resume+0x4a>
    if(p->state == ZOMBIE){
801052e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052e4:	8b 40 0c             	mov    0xc(%eax),%eax
801052e7:	83 f8 05             	cmp    $0x5,%eax
801052ea:	75 29                	jne    80105315 <resume+0x43>
      if(strcmp1(p->cont->name, name) == 0){
801052ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052ef:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052f5:	8d 50 18             	lea    0x18(%eax),%edx
801052f8:	8b 45 08             	mov    0x8(%ebp),%eax
801052fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801052ff:	89 14 24             	mov    %edx,(%esp)
80105302:	e8 c9 f7 ff ff       	call   80104ad0 <strcmp1>
80105307:	85 c0                	test   %eax,%eax
80105309:	75 0a                	jne    80105315 <resume+0x43>
        p->state = RUNNABLE;
8010530b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010530e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
void
resume(char* name)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105315:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
8010531c:	81 7d fc 94 83 11 80 	cmpl   $0x80118394,-0x4(%ebp)
80105323:	72 bc                	jb     801052e1 <resume+0xf>
      if(strcmp1(p->cont->name, name) == 0){
        p->state = RUNNABLE;
      }
    }
  }
}
80105325:	c9                   	leave  
80105326:	c3                   	ret    

80105327 <initp>:


struct proc* initp(void){
80105327:	55                   	push   %ebp
80105328:	89 e5                	mov    %esp,%ebp
  return initproc;
8010532a:	a1 20 d9 10 80       	mov    0x8010d920,%eax
}
8010532f:	5d                   	pop    %ebp
80105330:	c3                   	ret    

80105331 <c_proc>:

struct proc* c_proc(void){
80105331:	55                   	push   %ebp
80105332:	89 e5                	mov    %esp,%ebp
80105334:	83 ec 08             	sub    $0x8,%esp
  return myproc();
80105337:	e8 f7 f1 ff ff       	call   80104533 <myproc>
}
8010533c:	c9                   	leave  
8010533d:	c3                   	ret    
	...

80105340 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
80105343:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80105346:	8b 45 08             	mov    0x8(%ebp),%eax
80105349:	83 c0 04             	add    $0x4,%eax
8010534c:	c7 44 24 04 04 9e 10 	movl   $0x80109e04,0x4(%esp)
80105353:	80 
80105354:	89 04 24             	mov    %eax,(%esp)
80105357:	e8 22 01 00 00       	call   8010547e <initlock>
  lk->name = name;
8010535c:	8b 45 08             	mov    0x8(%ebp),%eax
8010535f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105362:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105365:	8b 45 08             	mov    0x8(%ebp),%eax
80105368:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010536e:	8b 45 08             	mov    0x8(%ebp),%eax
80105371:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105378:	c9                   	leave  
80105379:	c3                   	ret    

8010537a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010537a:	55                   	push   %ebp
8010537b:	89 e5                	mov    %esp,%ebp
8010537d:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105380:	8b 45 08             	mov    0x8(%ebp),%eax
80105383:	83 c0 04             	add    $0x4,%eax
80105386:	89 04 24             	mov    %eax,(%esp)
80105389:	e8 11 01 00 00       	call   8010549f <acquire>
  while (lk->locked) {
8010538e:	eb 15                	jmp    801053a5 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105390:	8b 45 08             	mov    0x8(%ebp),%eax
80105393:	83 c0 04             	add    $0x4,%eax
80105396:	89 44 24 04          	mov    %eax,0x4(%esp)
8010539a:	8b 45 08             	mov    0x8(%ebp),%eax
8010539d:	89 04 24             	mov    %eax,(%esp)
801053a0:	e8 3f fa ff ff       	call   80104de4 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
801053a5:	8b 45 08             	mov    0x8(%ebp),%eax
801053a8:	8b 00                	mov    (%eax),%eax
801053aa:	85 c0                	test   %eax,%eax
801053ac:	75 e2                	jne    80105390 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
801053ae:	8b 45 08             	mov    0x8(%ebp),%eax
801053b1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801053b7:	e8 77 f1 ff ff       	call   80104533 <myproc>
801053bc:	8b 50 10             	mov    0x10(%eax),%edx
801053bf:	8b 45 08             	mov    0x8(%ebp),%eax
801053c2:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801053c5:	8b 45 08             	mov    0x8(%ebp),%eax
801053c8:	83 c0 04             	add    $0x4,%eax
801053cb:	89 04 24             	mov    %eax,(%esp)
801053ce:	e8 36 01 00 00       	call   80105509 <release>
}
801053d3:	c9                   	leave  
801053d4:	c3                   	ret    

801053d5 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801053d5:	55                   	push   %ebp
801053d6:	89 e5                	mov    %esp,%ebp
801053d8:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801053db:	8b 45 08             	mov    0x8(%ebp),%eax
801053de:	83 c0 04             	add    $0x4,%eax
801053e1:	89 04 24             	mov    %eax,(%esp)
801053e4:	e8 b6 00 00 00       	call   8010549f <acquire>
  lk->locked = 0;
801053e9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801053f2:	8b 45 08             	mov    0x8(%ebp),%eax
801053f5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801053fc:	8b 45 08             	mov    0x8(%ebp),%eax
801053ff:	89 04 24             	mov    %eax,(%esp)
80105402:	e8 b4 fa ff ff       	call   80104ebb <wakeup>
  release(&lk->lk);
80105407:	8b 45 08             	mov    0x8(%ebp),%eax
8010540a:	83 c0 04             	add    $0x4,%eax
8010540d:	89 04 24             	mov    %eax,(%esp)
80105410:	e8 f4 00 00 00       	call   80105509 <release>
}
80105415:	c9                   	leave  
80105416:	c3                   	ret    

80105417 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80105417:	55                   	push   %ebp
80105418:	89 e5                	mov    %esp,%ebp
8010541a:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
8010541d:	8b 45 08             	mov    0x8(%ebp),%eax
80105420:	83 c0 04             	add    $0x4,%eax
80105423:	89 04 24             	mov    %eax,(%esp)
80105426:	e8 74 00 00 00       	call   8010549f <acquire>
  r = lk->locked;
8010542b:	8b 45 08             	mov    0x8(%ebp),%eax
8010542e:	8b 00                	mov    (%eax),%eax
80105430:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105433:	8b 45 08             	mov    0x8(%ebp),%eax
80105436:	83 c0 04             	add    $0x4,%eax
80105439:	89 04 24             	mov    %eax,(%esp)
8010543c:	e8 c8 00 00 00       	call   80105509 <release>
  return r;
80105441:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105444:	c9                   	leave  
80105445:	c3                   	ret    
	...

80105448 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105448:	55                   	push   %ebp
80105449:	89 e5                	mov    %esp,%ebp
8010544b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010544e:	9c                   	pushf  
8010544f:	58                   	pop    %eax
80105450:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105453:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105456:	c9                   	leave  
80105457:	c3                   	ret    

80105458 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105458:	55                   	push   %ebp
80105459:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010545b:	fa                   	cli    
}
8010545c:	5d                   	pop    %ebp
8010545d:	c3                   	ret    

8010545e <sti>:

static inline void
sti(void)
{
8010545e:	55                   	push   %ebp
8010545f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105461:	fb                   	sti    
}
80105462:	5d                   	pop    %ebp
80105463:	c3                   	ret    

80105464 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105464:	55                   	push   %ebp
80105465:	89 e5                	mov    %esp,%ebp
80105467:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010546a:	8b 55 08             	mov    0x8(%ebp),%edx
8010546d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105470:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105473:	f0 87 02             	lock xchg %eax,(%edx)
80105476:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105479:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010547c:	c9                   	leave  
8010547d:	c3                   	ret    

8010547e <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010547e:	55                   	push   %ebp
8010547f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105481:	8b 45 08             	mov    0x8(%ebp),%eax
80105484:	8b 55 0c             	mov    0xc(%ebp),%edx
80105487:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010548a:	8b 45 08             	mov    0x8(%ebp),%eax
8010548d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105493:	8b 45 08             	mov    0x8(%ebp),%eax
80105496:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010549d:	5d                   	pop    %ebp
8010549e:	c3                   	ret    

8010549f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010549f:	55                   	push   %ebp
801054a0:	89 e5                	mov    %esp,%ebp
801054a2:	53                   	push   %ebx
801054a3:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801054a6:	e8 53 01 00 00       	call   801055fe <pushcli>
  if(holding(lk))
801054ab:	8b 45 08             	mov    0x8(%ebp),%eax
801054ae:	89 04 24             	mov    %eax,(%esp)
801054b1:	e8 17 01 00 00       	call   801055cd <holding>
801054b6:	85 c0                	test   %eax,%eax
801054b8:	74 0c                	je     801054c6 <acquire+0x27>
    panic("acquire");
801054ba:	c7 04 24 0f 9e 10 80 	movl   $0x80109e0f,(%esp)
801054c1:	e8 8e b0 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801054c6:	90                   	nop
801054c7:	8b 45 08             	mov    0x8(%ebp),%eax
801054ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801054d1:	00 
801054d2:	89 04 24             	mov    %eax,(%esp)
801054d5:	e8 8a ff ff ff       	call   80105464 <xchg>
801054da:	85 c0                	test   %eax,%eax
801054dc:	75 e9                	jne    801054c7 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801054de:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801054e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
801054e6:	e8 c4 ef ff ff       	call   801044af <mycpu>
801054eb:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801054ee:	8b 45 08             	mov    0x8(%ebp),%eax
801054f1:	83 c0 0c             	add    $0xc,%eax
801054f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801054f8:	8d 45 08             	lea    0x8(%ebp),%eax
801054fb:	89 04 24             	mov    %eax,(%esp)
801054fe:	e8 53 00 00 00       	call   80105556 <getcallerpcs>
}
80105503:	83 c4 14             	add    $0x14,%esp
80105506:	5b                   	pop    %ebx
80105507:	5d                   	pop    %ebp
80105508:	c3                   	ret    

80105509 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105509:	55                   	push   %ebp
8010550a:	89 e5                	mov    %esp,%ebp
8010550c:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
8010550f:	8b 45 08             	mov    0x8(%ebp),%eax
80105512:	89 04 24             	mov    %eax,(%esp)
80105515:	e8 b3 00 00 00       	call   801055cd <holding>
8010551a:	85 c0                	test   %eax,%eax
8010551c:	75 0c                	jne    8010552a <release+0x21>
    panic("release");
8010551e:	c7 04 24 17 9e 10 80 	movl   $0x80109e17,(%esp)
80105525:	e8 2a b0 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
8010552a:	8b 45 08             	mov    0x8(%ebp),%eax
8010552d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105534:	8b 45 08             	mov    0x8(%ebp),%eax
80105537:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010553e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105543:	8b 45 08             	mov    0x8(%ebp),%eax
80105546:	8b 55 08             	mov    0x8(%ebp),%edx
80105549:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010554f:	e8 f4 00 00 00       	call   80105648 <popcli>
}
80105554:	c9                   	leave  
80105555:	c3                   	ret    

80105556 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105556:	55                   	push   %ebp
80105557:	89 e5                	mov    %esp,%ebp
80105559:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010555c:	8b 45 08             	mov    0x8(%ebp),%eax
8010555f:	83 e8 08             	sub    $0x8,%eax
80105562:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105565:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010556c:	eb 37                	jmp    801055a5 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010556e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105572:	74 37                	je     801055ab <getcallerpcs+0x55>
80105574:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010557b:	76 2e                	jbe    801055ab <getcallerpcs+0x55>
8010557d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105581:	74 28                	je     801055ab <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105583:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105586:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010558d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105590:	01 c2                	add    %eax,%edx
80105592:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105595:	8b 40 04             	mov    0x4(%eax),%eax
80105598:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010559a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010559d:	8b 00                	mov    (%eax),%eax
8010559f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801055a2:	ff 45 f8             	incl   -0x8(%ebp)
801055a5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801055a9:	7e c3                	jle    8010556e <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801055ab:	eb 18                	jmp    801055c5 <getcallerpcs+0x6f>
    pcs[i] = 0;
801055ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
801055b0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801055b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801055ba:	01 d0                	add    %edx,%eax
801055bc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801055c2:	ff 45 f8             	incl   -0x8(%ebp)
801055c5:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801055c9:	7e e2                	jle    801055ad <getcallerpcs+0x57>
    pcs[i] = 0;
}
801055cb:	c9                   	leave  
801055cc:	c3                   	ret    

801055cd <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801055cd:	55                   	push   %ebp
801055ce:	89 e5                	mov    %esp,%ebp
801055d0:	53                   	push   %ebx
801055d1:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801055d4:	8b 45 08             	mov    0x8(%ebp),%eax
801055d7:	8b 00                	mov    (%eax),%eax
801055d9:	85 c0                	test   %eax,%eax
801055db:	74 16                	je     801055f3 <holding+0x26>
801055dd:	8b 45 08             	mov    0x8(%ebp),%eax
801055e0:	8b 58 08             	mov    0x8(%eax),%ebx
801055e3:	e8 c7 ee ff ff       	call   801044af <mycpu>
801055e8:	39 c3                	cmp    %eax,%ebx
801055ea:	75 07                	jne    801055f3 <holding+0x26>
801055ec:	b8 01 00 00 00       	mov    $0x1,%eax
801055f1:	eb 05                	jmp    801055f8 <holding+0x2b>
801055f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055f8:	83 c4 04             	add    $0x4,%esp
801055fb:	5b                   	pop    %ebx
801055fc:	5d                   	pop    %ebp
801055fd:	c3                   	ret    

801055fe <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801055fe:	55                   	push   %ebp
801055ff:	89 e5                	mov    %esp,%ebp
80105601:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105604:	e8 3f fe ff ff       	call   80105448 <readeflags>
80105609:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010560c:	e8 47 fe ff ff       	call   80105458 <cli>
  if(mycpu()->ncli == 0)
80105611:	e8 99 ee ff ff       	call   801044af <mycpu>
80105616:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010561c:	85 c0                	test   %eax,%eax
8010561e:	75 14                	jne    80105634 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105620:	e8 8a ee ff ff       	call   801044af <mycpu>
80105625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105628:	81 e2 00 02 00 00    	and    $0x200,%edx
8010562e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105634:	e8 76 ee ff ff       	call   801044af <mycpu>
80105639:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010563f:	42                   	inc    %edx
80105640:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105646:	c9                   	leave  
80105647:	c3                   	ret    

80105648 <popcli>:

void
popcli(void)
{
80105648:	55                   	push   %ebp
80105649:	89 e5                	mov    %esp,%ebp
8010564b:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010564e:	e8 f5 fd ff ff       	call   80105448 <readeflags>
80105653:	25 00 02 00 00       	and    $0x200,%eax
80105658:	85 c0                	test   %eax,%eax
8010565a:	74 0c                	je     80105668 <popcli+0x20>
    panic("popcli - interruptible");
8010565c:	c7 04 24 1f 9e 10 80 	movl   $0x80109e1f,(%esp)
80105663:	e8 ec ae ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105668:	e8 42 ee ff ff       	call   801044af <mycpu>
8010566d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105673:	4a                   	dec    %edx
80105674:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010567a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105680:	85 c0                	test   %eax,%eax
80105682:	79 0c                	jns    80105690 <popcli+0x48>
    panic("popcli");
80105684:	c7 04 24 36 9e 10 80 	movl   $0x80109e36,(%esp)
8010568b:	e8 c4 ae ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105690:	e8 1a ee ff ff       	call   801044af <mycpu>
80105695:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010569b:	85 c0                	test   %eax,%eax
8010569d:	75 14                	jne    801056b3 <popcli+0x6b>
8010569f:	e8 0b ee ff ff       	call   801044af <mycpu>
801056a4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801056aa:	85 c0                	test   %eax,%eax
801056ac:	74 05                	je     801056b3 <popcli+0x6b>
    sti();
801056ae:	e8 ab fd ff ff       	call   8010545e <sti>
}
801056b3:	c9                   	leave  
801056b4:	c3                   	ret    
801056b5:	00 00                	add    %al,(%eax)
	...

801056b8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801056b8:	55                   	push   %ebp
801056b9:	89 e5                	mov    %esp,%ebp
801056bb:	57                   	push   %edi
801056bc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801056bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
801056c0:	8b 55 10             	mov    0x10(%ebp),%edx
801056c3:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c6:	89 cb                	mov    %ecx,%ebx
801056c8:	89 df                	mov    %ebx,%edi
801056ca:	89 d1                	mov    %edx,%ecx
801056cc:	fc                   	cld    
801056cd:	f3 aa                	rep stos %al,%es:(%edi)
801056cf:	89 ca                	mov    %ecx,%edx
801056d1:	89 fb                	mov    %edi,%ebx
801056d3:	89 5d 08             	mov    %ebx,0x8(%ebp)
801056d6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801056d9:	5b                   	pop    %ebx
801056da:	5f                   	pop    %edi
801056db:	5d                   	pop    %ebp
801056dc:	c3                   	ret    

801056dd <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801056dd:	55                   	push   %ebp
801056de:	89 e5                	mov    %esp,%ebp
801056e0:	57                   	push   %edi
801056e1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801056e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801056e5:	8b 55 10             	mov    0x10(%ebp),%edx
801056e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801056eb:	89 cb                	mov    %ecx,%ebx
801056ed:	89 df                	mov    %ebx,%edi
801056ef:	89 d1                	mov    %edx,%ecx
801056f1:	fc                   	cld    
801056f2:	f3 ab                	rep stos %eax,%es:(%edi)
801056f4:	89 ca                	mov    %ecx,%edx
801056f6:	89 fb                	mov    %edi,%ebx
801056f8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801056fb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801056fe:	5b                   	pop    %ebx
801056ff:	5f                   	pop    %edi
80105700:	5d                   	pop    %ebp
80105701:	c3                   	ret    

80105702 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105702:	55                   	push   %ebp
80105703:	89 e5                	mov    %esp,%ebp
80105705:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105708:	8b 45 08             	mov    0x8(%ebp),%eax
8010570b:	83 e0 03             	and    $0x3,%eax
8010570e:	85 c0                	test   %eax,%eax
80105710:	75 49                	jne    8010575b <memset+0x59>
80105712:	8b 45 10             	mov    0x10(%ebp),%eax
80105715:	83 e0 03             	and    $0x3,%eax
80105718:	85 c0                	test   %eax,%eax
8010571a:	75 3f                	jne    8010575b <memset+0x59>
    c &= 0xFF;
8010571c:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105723:	8b 45 10             	mov    0x10(%ebp),%eax
80105726:	c1 e8 02             	shr    $0x2,%eax
80105729:	89 c2                	mov    %eax,%edx
8010572b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010572e:	c1 e0 18             	shl    $0x18,%eax
80105731:	89 c1                	mov    %eax,%ecx
80105733:	8b 45 0c             	mov    0xc(%ebp),%eax
80105736:	c1 e0 10             	shl    $0x10,%eax
80105739:	09 c1                	or     %eax,%ecx
8010573b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010573e:	c1 e0 08             	shl    $0x8,%eax
80105741:	09 c8                	or     %ecx,%eax
80105743:	0b 45 0c             	or     0xc(%ebp),%eax
80105746:	89 54 24 08          	mov    %edx,0x8(%esp)
8010574a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010574e:	8b 45 08             	mov    0x8(%ebp),%eax
80105751:	89 04 24             	mov    %eax,(%esp)
80105754:	e8 84 ff ff ff       	call   801056dd <stosl>
80105759:	eb 19                	jmp    80105774 <memset+0x72>
  } else
    stosb(dst, c, n);
8010575b:	8b 45 10             	mov    0x10(%ebp),%eax
8010575e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105762:	8b 45 0c             	mov    0xc(%ebp),%eax
80105765:	89 44 24 04          	mov    %eax,0x4(%esp)
80105769:	8b 45 08             	mov    0x8(%ebp),%eax
8010576c:	89 04 24             	mov    %eax,(%esp)
8010576f:	e8 44 ff ff ff       	call   801056b8 <stosb>
  return dst;
80105774:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105777:	c9                   	leave  
80105778:	c3                   	ret    

80105779 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105779:	55                   	push   %ebp
8010577a:	89 e5                	mov    %esp,%ebp
8010577c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010577f:	8b 45 08             	mov    0x8(%ebp),%eax
80105782:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105785:	8b 45 0c             	mov    0xc(%ebp),%eax
80105788:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010578b:	eb 2a                	jmp    801057b7 <memcmp+0x3e>
    if(*s1 != *s2)
8010578d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105790:	8a 10                	mov    (%eax),%dl
80105792:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105795:	8a 00                	mov    (%eax),%al
80105797:	38 c2                	cmp    %al,%dl
80105799:	74 16                	je     801057b1 <memcmp+0x38>
      return *s1 - *s2;
8010579b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010579e:	8a 00                	mov    (%eax),%al
801057a0:	0f b6 d0             	movzbl %al,%edx
801057a3:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057a6:	8a 00                	mov    (%eax),%al
801057a8:	0f b6 c0             	movzbl %al,%eax
801057ab:	29 c2                	sub    %eax,%edx
801057ad:	89 d0                	mov    %edx,%eax
801057af:	eb 18                	jmp    801057c9 <memcmp+0x50>
    s1++, s2++;
801057b1:	ff 45 fc             	incl   -0x4(%ebp)
801057b4:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801057b7:	8b 45 10             	mov    0x10(%ebp),%eax
801057ba:	8d 50 ff             	lea    -0x1(%eax),%edx
801057bd:	89 55 10             	mov    %edx,0x10(%ebp)
801057c0:	85 c0                	test   %eax,%eax
801057c2:	75 c9                	jne    8010578d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801057c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057c9:	c9                   	leave  
801057ca:	c3                   	ret    

801057cb <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801057cb:	55                   	push   %ebp
801057cc:	89 e5                	mov    %esp,%ebp
801057ce:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801057d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801057d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801057d7:	8b 45 08             	mov    0x8(%ebp),%eax
801057da:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801057dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057e0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801057e3:	73 3a                	jae    8010581f <memmove+0x54>
801057e5:	8b 45 10             	mov    0x10(%ebp),%eax
801057e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057eb:	01 d0                	add    %edx,%eax
801057ed:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801057f0:	76 2d                	jbe    8010581f <memmove+0x54>
    s += n;
801057f2:	8b 45 10             	mov    0x10(%ebp),%eax
801057f5:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801057f8:	8b 45 10             	mov    0x10(%ebp),%eax
801057fb:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801057fe:	eb 10                	jmp    80105810 <memmove+0x45>
      *--d = *--s;
80105800:	ff 4d f8             	decl   -0x8(%ebp)
80105803:	ff 4d fc             	decl   -0x4(%ebp)
80105806:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105809:	8a 10                	mov    (%eax),%dl
8010580b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010580e:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105810:	8b 45 10             	mov    0x10(%ebp),%eax
80105813:	8d 50 ff             	lea    -0x1(%eax),%edx
80105816:	89 55 10             	mov    %edx,0x10(%ebp)
80105819:	85 c0                	test   %eax,%eax
8010581b:	75 e3                	jne    80105800 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010581d:	eb 25                	jmp    80105844 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010581f:	eb 16                	jmp    80105837 <memmove+0x6c>
      *d++ = *s++;
80105821:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105824:	8d 50 01             	lea    0x1(%eax),%edx
80105827:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010582a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010582d:	8d 4a 01             	lea    0x1(%edx),%ecx
80105830:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105833:	8a 12                	mov    (%edx),%dl
80105835:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105837:	8b 45 10             	mov    0x10(%ebp),%eax
8010583a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010583d:	89 55 10             	mov    %edx,0x10(%ebp)
80105840:	85 c0                	test   %eax,%eax
80105842:	75 dd                	jne    80105821 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105844:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105847:	c9                   	leave  
80105848:	c3                   	ret    

80105849 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105849:	55                   	push   %ebp
8010584a:	89 e5                	mov    %esp,%ebp
8010584c:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010584f:	8b 45 10             	mov    0x10(%ebp),%eax
80105852:	89 44 24 08          	mov    %eax,0x8(%esp)
80105856:	8b 45 0c             	mov    0xc(%ebp),%eax
80105859:	89 44 24 04          	mov    %eax,0x4(%esp)
8010585d:	8b 45 08             	mov    0x8(%ebp),%eax
80105860:	89 04 24             	mov    %eax,(%esp)
80105863:	e8 63 ff ff ff       	call   801057cb <memmove>
}
80105868:	c9                   	leave  
80105869:	c3                   	ret    

8010586a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010586a:	55                   	push   %ebp
8010586b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010586d:	eb 09                	jmp    80105878 <strncmp+0xe>
    n--, p++, q++;
8010586f:	ff 4d 10             	decl   0x10(%ebp)
80105872:	ff 45 08             	incl   0x8(%ebp)
80105875:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105878:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010587c:	74 17                	je     80105895 <strncmp+0x2b>
8010587e:	8b 45 08             	mov    0x8(%ebp),%eax
80105881:	8a 00                	mov    (%eax),%al
80105883:	84 c0                	test   %al,%al
80105885:	74 0e                	je     80105895 <strncmp+0x2b>
80105887:	8b 45 08             	mov    0x8(%ebp),%eax
8010588a:	8a 10                	mov    (%eax),%dl
8010588c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010588f:	8a 00                	mov    (%eax),%al
80105891:	38 c2                	cmp    %al,%dl
80105893:	74 da                	je     8010586f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105895:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105899:	75 07                	jne    801058a2 <strncmp+0x38>
    return 0;
8010589b:	b8 00 00 00 00       	mov    $0x0,%eax
801058a0:	eb 14                	jmp    801058b6 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
801058a2:	8b 45 08             	mov    0x8(%ebp),%eax
801058a5:	8a 00                	mov    (%eax),%al
801058a7:	0f b6 d0             	movzbl %al,%edx
801058aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801058ad:	8a 00                	mov    (%eax),%al
801058af:	0f b6 c0             	movzbl %al,%eax
801058b2:	29 c2                	sub    %eax,%edx
801058b4:	89 d0                	mov    %edx,%eax
}
801058b6:	5d                   	pop    %ebp
801058b7:	c3                   	ret    

801058b8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801058b8:	55                   	push   %ebp
801058b9:	89 e5                	mov    %esp,%ebp
801058bb:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801058be:	8b 45 08             	mov    0x8(%ebp),%eax
801058c1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801058c4:	90                   	nop
801058c5:	8b 45 10             	mov    0x10(%ebp),%eax
801058c8:	8d 50 ff             	lea    -0x1(%eax),%edx
801058cb:	89 55 10             	mov    %edx,0x10(%ebp)
801058ce:	85 c0                	test   %eax,%eax
801058d0:	7e 1c                	jle    801058ee <strncpy+0x36>
801058d2:	8b 45 08             	mov    0x8(%ebp),%eax
801058d5:	8d 50 01             	lea    0x1(%eax),%edx
801058d8:	89 55 08             	mov    %edx,0x8(%ebp)
801058db:	8b 55 0c             	mov    0xc(%ebp),%edx
801058de:	8d 4a 01             	lea    0x1(%edx),%ecx
801058e1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801058e4:	8a 12                	mov    (%edx),%dl
801058e6:	88 10                	mov    %dl,(%eax)
801058e8:	8a 00                	mov    (%eax),%al
801058ea:	84 c0                	test   %al,%al
801058ec:	75 d7                	jne    801058c5 <strncpy+0xd>
    ;
  while(n-- > 0)
801058ee:	eb 0c                	jmp    801058fc <strncpy+0x44>
    *s++ = 0;
801058f0:	8b 45 08             	mov    0x8(%ebp),%eax
801058f3:	8d 50 01             	lea    0x1(%eax),%edx
801058f6:	89 55 08             	mov    %edx,0x8(%ebp)
801058f9:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801058fc:	8b 45 10             	mov    0x10(%ebp),%eax
801058ff:	8d 50 ff             	lea    -0x1(%eax),%edx
80105902:	89 55 10             	mov    %edx,0x10(%ebp)
80105905:	85 c0                	test   %eax,%eax
80105907:	7f e7                	jg     801058f0 <strncpy+0x38>
    *s++ = 0;
  return os;
80105909:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010590c:	c9                   	leave  
8010590d:	c3                   	ret    

8010590e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010590e:	55                   	push   %ebp
8010590f:	89 e5                	mov    %esp,%ebp
80105911:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105914:	8b 45 08             	mov    0x8(%ebp),%eax
80105917:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
8010591a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010591e:	7f 05                	jg     80105925 <safestrcpy+0x17>
    return os;
80105920:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105923:	eb 2e                	jmp    80105953 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105925:	ff 4d 10             	decl   0x10(%ebp)
80105928:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010592c:	7e 1c                	jle    8010594a <safestrcpy+0x3c>
8010592e:	8b 45 08             	mov    0x8(%ebp),%eax
80105931:	8d 50 01             	lea    0x1(%eax),%edx
80105934:	89 55 08             	mov    %edx,0x8(%ebp)
80105937:	8b 55 0c             	mov    0xc(%ebp),%edx
8010593a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010593d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105940:	8a 12                	mov    (%edx),%dl
80105942:	88 10                	mov    %dl,(%eax)
80105944:	8a 00                	mov    (%eax),%al
80105946:	84 c0                	test   %al,%al
80105948:	75 db                	jne    80105925 <safestrcpy+0x17>
    ;
  *s = 0;
8010594a:	8b 45 08             	mov    0x8(%ebp),%eax
8010594d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105950:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105953:	c9                   	leave  
80105954:	c3                   	ret    

80105955 <strlen>:

int
strlen(const char *s)
{
80105955:	55                   	push   %ebp
80105956:	89 e5                	mov    %esp,%ebp
80105958:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010595b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105962:	eb 03                	jmp    80105967 <strlen+0x12>
80105964:	ff 45 fc             	incl   -0x4(%ebp)
80105967:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010596a:	8b 45 08             	mov    0x8(%ebp),%eax
8010596d:	01 d0                	add    %edx,%eax
8010596f:	8a 00                	mov    (%eax),%al
80105971:	84 c0                	test   %al,%al
80105973:	75 ef                	jne    80105964 <strlen+0xf>
    ;
  return n;
80105975:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105978:	c9                   	leave  
80105979:	c3                   	ret    
	...

8010597c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010597c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105980:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105984:	55                   	push   %ebp
  pushl %ebx
80105985:	53                   	push   %ebx
  pushl %esi
80105986:	56                   	push   %esi
  pushl %edi
80105987:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105988:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010598a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010598c:	5f                   	pop    %edi
  popl %esi
8010598d:	5e                   	pop    %esi
  popl %ebx
8010598e:	5b                   	pop    %ebx
  popl %ebp
8010598f:	5d                   	pop    %ebp
  ret
80105990:	c3                   	ret    
80105991:	00 00                	add    %al,(%eax)
	...

80105994 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105994:	55                   	push   %ebp
80105995:	89 e5                	mov    %esp,%ebp
80105997:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010599a:	e8 94 eb ff ff       	call   80104533 <myproc>
8010599f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801059a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059a5:	8b 00                	mov    (%eax),%eax
801059a7:	3b 45 08             	cmp    0x8(%ebp),%eax
801059aa:	76 0f                	jbe    801059bb <fetchint+0x27>
801059ac:	8b 45 08             	mov    0x8(%ebp),%eax
801059af:	8d 50 04             	lea    0x4(%eax),%edx
801059b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059b5:	8b 00                	mov    (%eax),%eax
801059b7:	39 c2                	cmp    %eax,%edx
801059b9:	76 07                	jbe    801059c2 <fetchint+0x2e>
    return -1;
801059bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c0:	eb 0f                	jmp    801059d1 <fetchint+0x3d>
  *ip = *(int*)(addr);
801059c2:	8b 45 08             	mov    0x8(%ebp),%eax
801059c5:	8b 10                	mov    (%eax),%edx
801059c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801059ca:	89 10                	mov    %edx,(%eax)
  return 0;
801059cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059d1:	c9                   	leave  
801059d2:	c3                   	ret    

801059d3 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801059d3:	55                   	push   %ebp
801059d4:	89 e5                	mov    %esp,%ebp
801059d6:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801059d9:	e8 55 eb ff ff       	call   80104533 <myproc>
801059de:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801059e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059e4:	8b 00                	mov    (%eax),%eax
801059e6:	3b 45 08             	cmp    0x8(%ebp),%eax
801059e9:	77 07                	ja     801059f2 <fetchstr+0x1f>
    return -1;
801059eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f0:	eb 41                	jmp    80105a33 <fetchstr+0x60>
  *pp = (char*)addr;
801059f2:	8b 55 08             	mov    0x8(%ebp),%edx
801059f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801059f8:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801059fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059fd:	8b 00                	mov    (%eax),%eax
801059ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a05:	8b 00                	mov    (%eax),%eax
80105a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a0a:	eb 1a                	jmp    80105a26 <fetchstr+0x53>
    if(*s == 0)
80105a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0f:	8a 00                	mov    (%eax),%al
80105a11:	84 c0                	test   %al,%al
80105a13:	75 0e                	jne    80105a23 <fetchstr+0x50>
      return s - *pp;
80105a15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a18:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a1b:	8b 00                	mov    (%eax),%eax
80105a1d:	29 c2                	sub    %eax,%edx
80105a1f:	89 d0                	mov    %edx,%eax
80105a21:	eb 10                	jmp    80105a33 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105a23:	ff 45 f4             	incl   -0xc(%ebp)
80105a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a29:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105a2c:	72 de                	jb     80105a0c <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105a2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a33:	c9                   	leave  
80105a34:	c3                   	ret    

80105a35 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105a35:	55                   	push   %ebp
80105a36:	89 e5                	mov    %esp,%ebp
80105a38:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105a3b:	e8 f3 ea ff ff       	call   80104533 <myproc>
80105a40:	8b 40 18             	mov    0x18(%eax),%eax
80105a43:	8b 50 44             	mov    0x44(%eax),%edx
80105a46:	8b 45 08             	mov    0x8(%ebp),%eax
80105a49:	c1 e0 02             	shl    $0x2,%eax
80105a4c:	01 d0                	add    %edx,%eax
80105a4e:	8d 50 04             	lea    0x4(%eax),%edx
80105a51:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a58:	89 14 24             	mov    %edx,(%esp)
80105a5b:	e8 34 ff ff ff       	call   80105994 <fetchint>
}
80105a60:	c9                   	leave  
80105a61:	c3                   	ret    

80105a62 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105a62:	55                   	push   %ebp
80105a63:	89 e5                	mov    %esp,%ebp
80105a65:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105a68:	e8 c6 ea ff ff       	call   80104533 <myproc>
80105a6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105a70:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a73:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a77:	8b 45 08             	mov    0x8(%ebp),%eax
80105a7a:	89 04 24             	mov    %eax,(%esp)
80105a7d:	e8 b3 ff ff ff       	call   80105a35 <argint>
80105a82:	85 c0                	test   %eax,%eax
80105a84:	79 07                	jns    80105a8d <argptr+0x2b>
    return -1;
80105a86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a8b:	eb 3d                	jmp    80105aca <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105a8d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a91:	78 21                	js     80105ab4 <argptr+0x52>
80105a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a96:	89 c2                	mov    %eax,%edx
80105a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9b:	8b 00                	mov    (%eax),%eax
80105a9d:	39 c2                	cmp    %eax,%edx
80105a9f:	73 13                	jae    80105ab4 <argptr+0x52>
80105aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa4:	89 c2                	mov    %eax,%edx
80105aa6:	8b 45 10             	mov    0x10(%ebp),%eax
80105aa9:	01 c2                	add    %eax,%edx
80105aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aae:	8b 00                	mov    (%eax),%eax
80105ab0:	39 c2                	cmp    %eax,%edx
80105ab2:	76 07                	jbe    80105abb <argptr+0x59>
    return -1;
80105ab4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab9:	eb 0f                	jmp    80105aca <argptr+0x68>
  *pp = (char*)i;
80105abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105abe:	89 c2                	mov    %eax,%edx
80105ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ac3:	89 10                	mov    %edx,(%eax)
  return 0;
80105ac5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aca:	c9                   	leave  
80105acb:	c3                   	ret    

80105acc <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105acc:	55                   	push   %ebp
80105acd:	89 e5                	mov    %esp,%ebp
80105acf:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105ad2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ad5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80105adc:	89 04 24             	mov    %eax,(%esp)
80105adf:	e8 51 ff ff ff       	call   80105a35 <argint>
80105ae4:	85 c0                	test   %eax,%eax
80105ae6:	79 07                	jns    80105aef <argstr+0x23>
    return -1;
80105ae8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aed:	eb 12                	jmp    80105b01 <argstr+0x35>
  return fetchstr(addr, pp);
80105aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105af2:	8b 55 0c             	mov    0xc(%ebp),%edx
80105af5:	89 54 24 04          	mov    %edx,0x4(%esp)
80105af9:	89 04 24             	mov    %eax,(%esp)
80105afc:	e8 d2 fe ff ff       	call   801059d3 <fetchstr>
}
80105b01:	c9                   	leave  
80105b02:	c3                   	ret    

80105b03 <syscall>:
[SYS_c_ps] sys_c_ps,
};

void
syscall(void)
{
80105b03:	55                   	push   %ebp
80105b04:	89 e5                	mov    %esp,%ebp
80105b06:	53                   	push   %ebx
80105b07:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105b0a:	e8 24 ea ff ff       	call   80104533 <myproc>
80105b0f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b15:	8b 40 18             	mov    0x18(%eax),%eax
80105b18:	8b 40 1c             	mov    0x1c(%eax),%eax
80105b1b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105b1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b22:	7e 2d                	jle    80105b51 <syscall+0x4e>
80105b24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b27:	83 f8 34             	cmp    $0x34,%eax
80105b2a:	77 25                	ja     80105b51 <syscall+0x4e>
80105b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b2f:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105b36:	85 c0                	test   %eax,%eax
80105b38:	74 17                	je     80105b51 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3d:	8b 58 18             	mov    0x18(%eax),%ebx
80105b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b43:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105b4a:	ff d0                	call   *%eax
80105b4c:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105b4f:	eb 34                	jmp    80105b85 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b54:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b5a:	8b 40 10             	mov    0x10(%eax),%eax
80105b5d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b60:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105b64:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b68:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b6c:	c7 04 24 3d 9e 10 80 	movl   $0x80109e3d,(%esp)
80105b73:	e8 49 a8 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b7b:	8b 40 18             	mov    0x18(%eax),%eax
80105b7e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105b85:	83 c4 24             	add    $0x24,%esp
80105b88:	5b                   	pop    %ebx
80105b89:	5d                   	pop    %ebp
80105b8a:	c3                   	ret    
	...

80105b8c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105b8c:	55                   	push   %ebp
80105b8d:	89 e5                	mov    %esp,%ebp
80105b8f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105b92:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b95:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b99:	8b 45 08             	mov    0x8(%ebp),%eax
80105b9c:	89 04 24             	mov    %eax,(%esp)
80105b9f:	e8 91 fe ff ff       	call   80105a35 <argint>
80105ba4:	85 c0                	test   %eax,%eax
80105ba6:	79 07                	jns    80105baf <argfd+0x23>
    return -1;
80105ba8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bad:	eb 4f                	jmp    80105bfe <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb2:	85 c0                	test   %eax,%eax
80105bb4:	78 20                	js     80105bd6 <argfd+0x4a>
80105bb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb9:	83 f8 0f             	cmp    $0xf,%eax
80105bbc:	7f 18                	jg     80105bd6 <argfd+0x4a>
80105bbe:	e8 70 e9 ff ff       	call   80104533 <myproc>
80105bc3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105bc6:	83 c2 08             	add    $0x8,%edx
80105bc9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105bcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bd0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bd4:	75 07                	jne    80105bdd <argfd+0x51>
    return -1;
80105bd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bdb:	eb 21                	jmp    80105bfe <argfd+0x72>
  if(pfd)
80105bdd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105be1:	74 08                	je     80105beb <argfd+0x5f>
    *pfd = fd;
80105be3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105be6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105be9:	89 10                	mov    %edx,(%eax)
  if(pf)
80105beb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105bef:	74 08                	je     80105bf9 <argfd+0x6d>
    *pf = f;
80105bf1:	8b 45 10             	mov    0x10(%ebp),%eax
80105bf4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bf7:	89 10                	mov    %edx,(%eax)
  return 0;
80105bf9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bfe:	c9                   	leave  
80105bff:	c3                   	ret    

80105c00 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105c00:	55                   	push   %ebp
80105c01:	89 e5                	mov    %esp,%ebp
80105c03:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105c06:	e8 28 e9 ff ff       	call   80104533 <myproc>
80105c0b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105c0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105c15:	eb 29                	jmp    80105c40 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105c17:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c1d:	83 c2 08             	add    $0x8,%edx
80105c20:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105c24:	85 c0                	test   %eax,%eax
80105c26:	75 15                	jne    80105c3d <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105c28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c2e:	8d 4a 08             	lea    0x8(%edx),%ecx
80105c31:	8b 55 08             	mov    0x8(%ebp),%edx
80105c34:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c3b:	eb 0e                	jmp    80105c4b <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105c3d:	ff 45 f4             	incl   -0xc(%ebp)
80105c40:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105c44:	7e d1                	jle    80105c17 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105c46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c4b:	c9                   	leave  
80105c4c:	c3                   	ret    

80105c4d <sys_dup>:

int
sys_dup(void)
{
80105c4d:	55                   	push   %ebp
80105c4e:	89 e5                	mov    %esp,%ebp
80105c50:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105c53:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c56:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c61:	00 
80105c62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c69:	e8 1e ff ff ff       	call   80105b8c <argfd>
80105c6e:	85 c0                	test   %eax,%eax
80105c70:	79 07                	jns    80105c79 <sys_dup+0x2c>
    return -1;
80105c72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c77:	eb 29                	jmp    80105ca2 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c7c:	89 04 24             	mov    %eax,(%esp)
80105c7f:	e8 7c ff ff ff       	call   80105c00 <fdalloc>
80105c84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c8b:	79 07                	jns    80105c94 <sys_dup+0x47>
    return -1;
80105c8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c92:	eb 0e                	jmp    80105ca2 <sys_dup+0x55>
  filedup(f);
80105c94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c97:	89 04 24             	mov    %eax,(%esp)
80105c9a:	e8 c3 b4 ff ff       	call   80101162 <filedup>
  return fd;
80105c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105ca2:	c9                   	leave  
80105ca3:	c3                   	ret    

80105ca4 <sys_read>:

int
sys_read(void)
{
80105ca4:	55                   	push   %ebp
80105ca5:	89 e5                	mov    %esp,%ebp
80105ca7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105caa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105cad:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cb1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cb8:	00 
80105cb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cc0:	e8 c7 fe ff ff       	call   80105b8c <argfd>
80105cc5:	85 c0                	test   %eax,%eax
80105cc7:	78 35                	js     80105cfe <sys_read+0x5a>
80105cc9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cd0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105cd7:	e8 59 fd ff ff       	call   80105a35 <argint>
80105cdc:	85 c0                	test   %eax,%eax
80105cde:	78 1e                	js     80105cfe <sys_read+0x5a>
80105ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ce7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105cea:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cf5:	e8 68 fd ff ff       	call   80105a62 <argptr>
80105cfa:	85 c0                	test   %eax,%eax
80105cfc:	79 07                	jns    80105d05 <sys_read+0x61>
    return -1;
80105cfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d03:	eb 19                	jmp    80105d1e <sys_read+0x7a>
  return fileread(f, p, n);
80105d05:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d08:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d12:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d16:	89 04 24             	mov    %eax,(%esp)
80105d19:	e8 a5 b5 ff ff       	call   801012c3 <fileread>
}
80105d1e:	c9                   	leave  
80105d1f:	c3                   	ret    

80105d20 <sys_write>:

int
sys_write(void)
{
80105d20:	55                   	push   %ebp
80105d21:	89 e5                	mov    %esp,%ebp
80105d23:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d26:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d29:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d2d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d34:	00 
80105d35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d3c:	e8 4b fe ff ff       	call   80105b8c <argfd>
80105d41:	85 c0                	test   %eax,%eax
80105d43:	78 35                	js     80105d7a <sys_write+0x5a>
80105d45:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d48:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d4c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105d53:	e8 dd fc ff ff       	call   80105a35 <argint>
80105d58:	85 c0                	test   %eax,%eax
80105d5a:	78 1e                	js     80105d7a <sys_write+0x5a>
80105d5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d63:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d66:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d71:	e8 ec fc ff ff       	call   80105a62 <argptr>
80105d76:	85 c0                	test   %eax,%eax
80105d78:	79 07                	jns    80105d81 <sys_write+0x61>
    return -1;
80105d7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d7f:	eb 19                	jmp    80105d9a <sys_write+0x7a>
  return filewrite(f, p, n);
80105d81:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d84:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d8a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d8e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d92:	89 04 24             	mov    %eax,(%esp)
80105d95:	e8 e4 b5 ff ff       	call   8010137e <filewrite>
}
80105d9a:	c9                   	leave  
80105d9b:	c3                   	ret    

80105d9c <sys_close>:

int
sys_close(void)
{
80105d9c:	55                   	push   %ebp
80105d9d:	89 e5                	mov    %esp,%ebp
80105d9f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105da2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105da5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105da9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dac:	89 44 24 04          	mov    %eax,0x4(%esp)
80105db0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105db7:	e8 d0 fd ff ff       	call   80105b8c <argfd>
80105dbc:	85 c0                	test   %eax,%eax
80105dbe:	79 07                	jns    80105dc7 <sys_close+0x2b>
    return -1;
80105dc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc5:	eb 23                	jmp    80105dea <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105dc7:	e8 67 e7 ff ff       	call   80104533 <myproc>
80105dcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dcf:	83 c2 08             	add    $0x8,%edx
80105dd2:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105dd9:	00 
  fileclose(f);
80105dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ddd:	89 04 24             	mov    %eax,(%esp)
80105de0:	e8 c5 b3 ff ff       	call   801011aa <fileclose>
  return 0;
80105de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dea:	c9                   	leave  
80105deb:	c3                   	ret    

80105dec <sys_fstat>:

int
sys_fstat(void)
{
80105dec:	55                   	push   %ebp
80105ded:	89 e5                	mov    %esp,%ebp
80105def:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105df2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105df5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105df9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e00:	00 
80105e01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e08:	e8 7f fd ff ff       	call   80105b8c <argfd>
80105e0d:	85 c0                	test   %eax,%eax
80105e0f:	78 1f                	js     80105e30 <sys_fstat+0x44>
80105e11:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105e18:	00 
80105e19:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e20:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e27:	e8 36 fc ff ff       	call   80105a62 <argptr>
80105e2c:	85 c0                	test   %eax,%eax
80105e2e:	79 07                	jns    80105e37 <sys_fstat+0x4b>
    return -1;
80105e30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e35:	eb 12                	jmp    80105e49 <sys_fstat+0x5d>
  return filestat(f, st);
80105e37:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e3d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e41:	89 04 24             	mov    %eax,(%esp)
80105e44:	e8 2b b4 ff ff       	call   80101274 <filestat>
}
80105e49:	c9                   	leave  
80105e4a:	c3                   	ret    

80105e4b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105e4b:	55                   	push   %ebp
80105e4c:	89 e5                	mov    %esp,%ebp
80105e4e:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105e51:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105e54:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e5f:	e8 68 fc ff ff       	call   80105acc <argstr>
80105e64:	85 c0                	test   %eax,%eax
80105e66:	78 17                	js     80105e7f <sys_link+0x34>
80105e68:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105e6b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e76:	e8 51 fc ff ff       	call   80105acc <argstr>
80105e7b:	85 c0                	test   %eax,%eax
80105e7d:	79 0a                	jns    80105e89 <sys_link+0x3e>
    return -1;
80105e7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e84:	e9 3d 01 00 00       	jmp    80105fc6 <sys_link+0x17b>

  begin_op();
80105e89:	e8 7d d9 ff ff       	call   8010380b <begin_op>
  if((ip = namei(old)) == 0){
80105e8e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105e91:	89 04 24             	mov    %eax,(%esp)
80105e94:	e8 94 c8 ff ff       	call   8010272d <namei>
80105e99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e9c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ea0:	75 0f                	jne    80105eb1 <sys_link+0x66>
    end_op();
80105ea2:	e8 e6 d9 ff ff       	call   8010388d <end_op>
    return -1;
80105ea7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eac:	e9 15 01 00 00       	jmp    80105fc6 <sys_link+0x17b>
  }

  ilock(ip);
80105eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb4:	89 04 24             	mov    %eax,(%esp)
80105eb7:	e8 06 bc ff ff       	call   80101ac2 <ilock>
  if(ip->type == T_DIR){
80105ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebf:	8b 40 50             	mov    0x50(%eax),%eax
80105ec2:	66 83 f8 01          	cmp    $0x1,%ax
80105ec6:	75 1a                	jne    80105ee2 <sys_link+0x97>
    iunlockput(ip);
80105ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecb:	89 04 24             	mov    %eax,(%esp)
80105ece:	e8 ee bd ff ff       	call   80101cc1 <iunlockput>
    end_op();
80105ed3:	e8 b5 d9 ff ff       	call   8010388d <end_op>
    return -1;
80105ed8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105edd:	e9 e4 00 00 00       	jmp    80105fc6 <sys_link+0x17b>
  }

  ip->nlink++;
80105ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee5:	66 8b 40 56          	mov    0x56(%eax),%ax
80105ee9:	40                   	inc    %eax
80105eea:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105eed:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef4:	89 04 24             	mov    %eax,(%esp)
80105ef7:	e8 03 ba ff ff       	call   801018ff <iupdate>
  iunlock(ip);
80105efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eff:	89 04 24             	mov    %eax,(%esp)
80105f02:	e8 c5 bc ff ff       	call   80101bcc <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105f07:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105f0a:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105f0d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f11:	89 04 24             	mov    %eax,(%esp)
80105f14:	e8 36 c8 ff ff       	call   8010274f <nameiparent>
80105f19:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f20:	75 02                	jne    80105f24 <sys_link+0xd9>
    goto bad;
80105f22:	eb 68                	jmp    80105f8c <sys_link+0x141>
  ilock(dp);
80105f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f27:	89 04 24             	mov    %eax,(%esp)
80105f2a:	e8 93 bb ff ff       	call   80101ac2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105f2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f32:	8b 10                	mov    (%eax),%edx
80105f34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f37:	8b 00                	mov    (%eax),%eax
80105f39:	39 c2                	cmp    %eax,%edx
80105f3b:	75 20                	jne    80105f5d <sys_link+0x112>
80105f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f40:	8b 40 04             	mov    0x4(%eax),%eax
80105f43:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f47:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105f4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f51:	89 04 24             	mov    %eax,(%esp)
80105f54:	e8 19 c4 ff ff       	call   80102372 <dirlink>
80105f59:	85 c0                	test   %eax,%eax
80105f5b:	79 0d                	jns    80105f6a <sys_link+0x11f>
    iunlockput(dp);
80105f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f60:	89 04 24             	mov    %eax,(%esp)
80105f63:	e8 59 bd ff ff       	call   80101cc1 <iunlockput>
    goto bad;
80105f68:	eb 22                	jmp    80105f8c <sys_link+0x141>
  }
  iunlockput(dp);
80105f6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6d:	89 04 24             	mov    %eax,(%esp)
80105f70:	e8 4c bd ff ff       	call   80101cc1 <iunlockput>
  iput(ip);
80105f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f78:	89 04 24             	mov    %eax,(%esp)
80105f7b:	e8 90 bc ff ff       	call   80101c10 <iput>

  end_op();
80105f80:	e8 08 d9 ff ff       	call   8010388d <end_op>

  return 0;
80105f85:	b8 00 00 00 00       	mov    $0x0,%eax
80105f8a:	eb 3a                	jmp    80105fc6 <sys_link+0x17b>

bad:
  ilock(ip);
80105f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8f:	89 04 24             	mov    %eax,(%esp)
80105f92:	e8 2b bb ff ff       	call   80101ac2 <ilock>
  ip->nlink--;
80105f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9a:	66 8b 40 56          	mov    0x56(%eax),%ax
80105f9e:	48                   	dec    %eax
80105f9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fa2:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa9:	89 04 24             	mov    %eax,(%esp)
80105fac:	e8 4e b9 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80105fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb4:	89 04 24             	mov    %eax,(%esp)
80105fb7:	e8 05 bd ff ff       	call   80101cc1 <iunlockput>
  end_op();
80105fbc:	e8 cc d8 ff ff       	call   8010388d <end_op>
  return -1;
80105fc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105fc6:	c9                   	leave  
80105fc7:	c3                   	ret    

80105fc8 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105fc8:	55                   	push   %ebp
80105fc9:	89 e5                	mov    %esp,%ebp
80105fcb:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105fce:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105fd5:	eb 4a                	jmp    80106021 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fda:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105fe1:	00 
80105fe2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fe6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fe9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fed:	8b 45 08             	mov    0x8(%ebp),%eax
80105ff0:	89 04 24             	mov    %eax,(%esp)
80105ff3:	e8 61 bf ff ff       	call   80101f59 <readi>
80105ff8:	83 f8 10             	cmp    $0x10,%eax
80105ffb:	74 0c                	je     80106009 <isdirempty+0x41>
      panic("isdirempty: readi");
80105ffd:	c7 04 24 59 9e 10 80 	movl   $0x80109e59,(%esp)
80106004:	e8 4b a5 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80106009:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010600c:	66 85 c0             	test   %ax,%ax
8010600f:	74 07                	je     80106018 <isdirempty+0x50>
      return 0;
80106011:	b8 00 00 00 00       	mov    $0x0,%eax
80106016:	eb 1b                	jmp    80106033 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601b:	83 c0 10             	add    $0x10,%eax
8010601e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106021:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106024:	8b 45 08             	mov    0x8(%ebp),%eax
80106027:	8b 40 58             	mov    0x58(%eax),%eax
8010602a:	39 c2                	cmp    %eax,%edx
8010602c:	72 a9                	jb     80105fd7 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
8010602e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106033:	c9                   	leave  
80106034:	c3                   	ret    

80106035 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106035:	55                   	push   %ebp
80106036:	89 e5                	mov    %esp,%ebp
80106038:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010603b:	8d 45 bc             	lea    -0x44(%ebp),%eax
8010603e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106049:	e8 7e fa ff ff       	call   80105acc <argstr>
8010604e:	85 c0                	test   %eax,%eax
80106050:	79 0a                	jns    8010605c <sys_unlink+0x27>
    return -1;
80106052:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106057:	e9 f1 01 00 00       	jmp    8010624d <sys_unlink+0x218>

  begin_op();
8010605c:	e8 aa d7 ff ff       	call   8010380b <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106061:	8b 45 bc             	mov    -0x44(%ebp),%eax
80106064:	8d 55 c2             	lea    -0x3e(%ebp),%edx
80106067:	89 54 24 04          	mov    %edx,0x4(%esp)
8010606b:	89 04 24             	mov    %eax,(%esp)
8010606e:	e8 dc c6 ff ff       	call   8010274f <nameiparent>
80106073:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106076:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010607a:	75 0f                	jne    8010608b <sys_unlink+0x56>
    end_op();
8010607c:	e8 0c d8 ff ff       	call   8010388d <end_op>
    return -1;
80106081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106086:	e9 c2 01 00 00       	jmp    8010624d <sys_unlink+0x218>
  }

  ilock(dp);
8010608b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608e:	89 04 24             	mov    %eax,(%esp)
80106091:	e8 2c ba ff ff       	call   80101ac2 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106096:	c7 44 24 04 6b 9e 10 	movl   $0x80109e6b,0x4(%esp)
8010609d:	80 
8010609e:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801060a1:	89 04 24             	mov    %eax,(%esp)
801060a4:	e8 e1 c1 ff ff       	call   8010228a <namecmp>
801060a9:	85 c0                	test   %eax,%eax
801060ab:	0f 84 87 01 00 00    	je     80106238 <sys_unlink+0x203>
801060b1:	c7 44 24 04 6d 9e 10 	movl   $0x80109e6d,0x4(%esp)
801060b8:	80 
801060b9:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801060bc:	89 04 24             	mov    %eax,(%esp)
801060bf:	e8 c6 c1 ff ff       	call   8010228a <namecmp>
801060c4:	85 c0                	test   %eax,%eax
801060c6:	0f 84 6c 01 00 00    	je     80106238 <sys_unlink+0x203>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801060cc:	8d 45 b8             	lea    -0x48(%ebp),%eax
801060cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801060d3:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801060d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801060da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060dd:	89 04 24             	mov    %eax,(%esp)
801060e0:	e8 c7 c1 ff ff       	call   801022ac <dirlookup>
801060e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060ec:	75 05                	jne    801060f3 <sys_unlink+0xbe>
    goto bad;
801060ee:	e9 45 01 00 00       	jmp    80106238 <sys_unlink+0x203>
  ilock(ip);
801060f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f6:	89 04 24             	mov    %eax,(%esp)
801060f9:	e8 c4 b9 ff ff       	call   80101ac2 <ilock>

  if(ip->nlink < 1)
801060fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106101:	66 8b 40 56          	mov    0x56(%eax),%ax
80106105:	66 85 c0             	test   %ax,%ax
80106108:	7f 0c                	jg     80106116 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
8010610a:	c7 04 24 70 9e 10 80 	movl   $0x80109e70,(%esp)
80106111:	e8 3e a4 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106116:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106119:	8b 40 50             	mov    0x50(%eax),%eax
8010611c:	66 83 f8 01          	cmp    $0x1,%ax
80106120:	75 1f                	jne    80106141 <sys_unlink+0x10c>
80106122:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106125:	89 04 24             	mov    %eax,(%esp)
80106128:	e8 9b fe ff ff       	call   80105fc8 <isdirempty>
8010612d:	85 c0                	test   %eax,%eax
8010612f:	75 10                	jne    80106141 <sys_unlink+0x10c>
    iunlockput(ip);
80106131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106134:	89 04 24             	mov    %eax,(%esp)
80106137:	e8 85 bb ff ff       	call   80101cc1 <iunlockput>
    goto bad;
8010613c:	e9 f7 00 00 00       	jmp    80106238 <sys_unlink+0x203>
  }

  memset(&de, 0, sizeof(de));
80106141:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106148:	00 
80106149:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106150:	00 
80106151:	8d 45 d0             	lea    -0x30(%ebp),%eax
80106154:	89 04 24             	mov    %eax,(%esp)
80106157:	e8 a6 f5 ff ff       	call   80105702 <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
8010615c:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010615f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106166:	00 
80106167:	89 44 24 08          	mov    %eax,0x8(%esp)
8010616b:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010616e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106175:	89 04 24             	mov    %eax,(%esp)
80106178:	e8 40 bf ff ff       	call   801020bd <writei>
8010617d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
80106180:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
80106184:	74 0c                	je     80106192 <sys_unlink+0x15d>
    panic("unlink: writei");
80106186:	c7 04 24 82 9e 10 80 	movl   $0x80109e82,(%esp)
8010618d:	e8 c2 a3 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
80106192:	e8 9c e3 ff ff       	call   80104533 <myproc>
80106197:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010619d:	83 c0 18             	add    $0x18,%eax
801061a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
801061a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061a6:	89 04 24             	mov    %eax,(%esp)
801061a9:	e8 35 30 00 00       	call   801091e3 <find>
801061ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int set = z/2;
801061b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061b4:	89 c2                	mov    %eax,%edx
801061b6:	c1 ea 1f             	shr    $0x1f,%edx
801061b9:	01 d0                	add    %edx,%eax
801061bb:	d1 f8                	sar    %eax
801061bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_curr_disk(-set, x);
801061c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801061c3:	f7 d8                	neg    %eax
801061c5:	89 c2                	mov    %eax,%edx
801061c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ce:	89 14 24             	mov    %edx,(%esp)
801061d1:	e8 a2 33 00 00       	call   80109578 <set_curr_disk>
  if(ip->type == T_DIR){
801061d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d9:	8b 40 50             	mov    0x50(%eax),%eax
801061dc:	66 83 f8 01          	cmp    $0x1,%ax
801061e0:	75 1a                	jne    801061fc <sys_unlink+0x1c7>
    dp->nlink--;
801061e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e5:	66 8b 40 56          	mov    0x56(%eax),%ax
801061e9:	48                   	dec    %eax
801061ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061ed:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
801061f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f4:	89 04 24             	mov    %eax,(%esp)
801061f7:	e8 03 b7 ff ff       	call   801018ff <iupdate>
  }
  iunlockput(dp);
801061fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ff:	89 04 24             	mov    %eax,(%esp)
80106202:	e8 ba ba ff ff       	call   80101cc1 <iunlockput>

  ip->nlink--;
80106207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620a:	66 8b 40 56          	mov    0x56(%eax),%ax
8010620e:	48                   	dec    %eax
8010620f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106212:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106216:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106219:	89 04 24             	mov    %eax,(%esp)
8010621c:	e8 de b6 ff ff       	call   801018ff <iupdate>
  iunlockput(ip);
80106221:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106224:	89 04 24             	mov    %eax,(%esp)
80106227:	e8 95 ba ff ff       	call   80101cc1 <iunlockput>

  end_op();
8010622c:	e8 5c d6 ff ff       	call   8010388d <end_op>

  return 0;
80106231:	b8 00 00 00 00       	mov    $0x0,%eax
80106236:	eb 15                	jmp    8010624d <sys_unlink+0x218>

bad:
  iunlockput(dp);
80106238:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623b:	89 04 24             	mov    %eax,(%esp)
8010623e:	e8 7e ba ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106243:	e8 45 d6 ff ff       	call   8010388d <end_op>
  return -1;
80106248:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010624d:	c9                   	leave  
8010624e:	c3                   	ret    

8010624f <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010624f:	55                   	push   %ebp
80106250:	89 e5                	mov    %esp,%ebp
80106252:	83 ec 48             	sub    $0x48,%esp
80106255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106258:	8b 55 10             	mov    0x10(%ebp),%edx
8010625b:	8b 45 14             	mov    0x14(%ebp),%eax
8010625e:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106262:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106266:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010626a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010626d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106271:	8b 45 08             	mov    0x8(%ebp),%eax
80106274:	89 04 24             	mov    %eax,(%esp)
80106277:	e8 d3 c4 ff ff       	call   8010274f <nameiparent>
8010627c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010627f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106283:	75 0a                	jne    8010628f <create+0x40>
    return 0;
80106285:	b8 00 00 00 00       	mov    $0x0,%eax
8010628a:	e9 79 01 00 00       	jmp    80106408 <create+0x1b9>
  ilock(dp);
8010628f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106292:	89 04 24             	mov    %eax,(%esp)
80106295:	e8 28 b8 ff ff       	call   80101ac2 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010629a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010629d:	89 44 24 08          	mov    %eax,0x8(%esp)
801062a1:	8d 45 de             	lea    -0x22(%ebp),%eax
801062a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801062a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ab:	89 04 24             	mov    %eax,(%esp)
801062ae:	e8 f9 bf ff ff       	call   801022ac <dirlookup>
801062b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062b6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062ba:	74 46                	je     80106302 <create+0xb3>
    iunlockput(dp);
801062bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bf:	89 04 24             	mov    %eax,(%esp)
801062c2:	e8 fa b9 ff ff       	call   80101cc1 <iunlockput>
    ilock(ip);
801062c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ca:	89 04 24             	mov    %eax,(%esp)
801062cd:	e8 f0 b7 ff ff       	call   80101ac2 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801062d2:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801062d7:	75 14                	jne    801062ed <create+0x9e>
801062d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062dc:	8b 40 50             	mov    0x50(%eax),%eax
801062df:	66 83 f8 02          	cmp    $0x2,%ax
801062e3:	75 08                	jne    801062ed <create+0x9e>
      return ip;
801062e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062e8:	e9 1b 01 00 00       	jmp    80106408 <create+0x1b9>
    iunlockput(ip);
801062ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f0:	89 04 24             	mov    %eax,(%esp)
801062f3:	e8 c9 b9 ff ff       	call   80101cc1 <iunlockput>
    return 0;
801062f8:	b8 00 00 00 00       	mov    $0x0,%eax
801062fd:	e9 06 01 00 00       	jmp    80106408 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106302:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106306:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106309:	8b 00                	mov    (%eax),%eax
8010630b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010630f:	89 04 24             	mov    %eax,(%esp)
80106312:	e8 16 b5 ff ff       	call   8010182d <ialloc>
80106317:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010631a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010631e:	75 0c                	jne    8010632c <create+0xdd>
    panic("create: ialloc");
80106320:	c7 04 24 91 9e 10 80 	movl   $0x80109e91,(%esp)
80106327:	e8 28 a2 ff ff       	call   80100554 <panic>

  ilock(ip);
8010632c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010632f:	89 04 24             	mov    %eax,(%esp)
80106332:	e8 8b b7 ff ff       	call   80101ac2 <ilock>
  ip->major = major;
80106337:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010633a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010633d:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106341:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106344:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106347:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
8010634b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010634e:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106354:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106357:	89 04 24             	mov    %eax,(%esp)
8010635a:	e8 a0 b5 ff ff       	call   801018ff <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010635f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106364:	75 68                	jne    801063ce <create+0x17f>
    dp->nlink++;  // for ".."
80106366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106369:	66 8b 40 56          	mov    0x56(%eax),%ax
8010636d:	40                   	inc    %eax
8010636e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106371:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106375:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106378:	89 04 24             	mov    %eax,(%esp)
8010637b:	e8 7f b5 ff ff       	call   801018ff <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106383:	8b 40 04             	mov    0x4(%eax),%eax
80106386:	89 44 24 08          	mov    %eax,0x8(%esp)
8010638a:	c7 44 24 04 6b 9e 10 	movl   $0x80109e6b,0x4(%esp)
80106391:	80 
80106392:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106395:	89 04 24             	mov    %eax,(%esp)
80106398:	e8 d5 bf ff ff       	call   80102372 <dirlink>
8010639d:	85 c0                	test   %eax,%eax
8010639f:	78 21                	js     801063c2 <create+0x173>
801063a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a4:	8b 40 04             	mov    0x4(%eax),%eax
801063a7:	89 44 24 08          	mov    %eax,0x8(%esp)
801063ab:	c7 44 24 04 6d 9e 10 	movl   $0x80109e6d,0x4(%esp)
801063b2:	80 
801063b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b6:	89 04 24             	mov    %eax,(%esp)
801063b9:	e8 b4 bf ff ff       	call   80102372 <dirlink>
801063be:	85 c0                	test   %eax,%eax
801063c0:	79 0c                	jns    801063ce <create+0x17f>
      panic("create dots");
801063c2:	c7 04 24 a0 9e 10 80 	movl   $0x80109ea0,(%esp)
801063c9:	e8 86 a1 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801063ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d1:	8b 40 04             	mov    0x4(%eax),%eax
801063d4:	89 44 24 08          	mov    %eax,0x8(%esp)
801063d8:	8d 45 de             	lea    -0x22(%ebp),%eax
801063db:	89 44 24 04          	mov    %eax,0x4(%esp)
801063df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e2:	89 04 24             	mov    %eax,(%esp)
801063e5:	e8 88 bf ff ff       	call   80102372 <dirlink>
801063ea:	85 c0                	test   %eax,%eax
801063ec:	79 0c                	jns    801063fa <create+0x1ab>
    panic("create: dirlink");
801063ee:	c7 04 24 ac 9e 10 80 	movl   $0x80109eac,(%esp)
801063f5:	e8 5a a1 ff ff       	call   80100554 <panic>

  iunlockput(dp);
801063fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fd:	89 04 24             	mov    %eax,(%esp)
80106400:	e8 bc b8 ff ff       	call   80101cc1 <iunlockput>

  return ip;
80106405:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106408:	c9                   	leave  
80106409:	c3                   	ret    

8010640a <sys_open>:

int
sys_open(void)
{
8010640a:	55                   	push   %ebp
8010640b:	89 e5                	mov    %esp,%ebp
8010640d:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106410:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106413:	89 44 24 04          	mov    %eax,0x4(%esp)
80106417:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010641e:	e8 a9 f6 ff ff       	call   80105acc <argstr>
80106423:	85 c0                	test   %eax,%eax
80106425:	78 17                	js     8010643e <sys_open+0x34>
80106427:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010642a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010642e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106435:	e8 fb f5 ff ff       	call   80105a35 <argint>
8010643a:	85 c0                	test   %eax,%eax
8010643c:	79 0a                	jns    80106448 <sys_open+0x3e>
    return -1;
8010643e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106443:	e9 64 01 00 00       	jmp    801065ac <sys_open+0x1a2>

  begin_op();
80106448:	e8 be d3 ff ff       	call   8010380b <begin_op>

  if(omode & O_CREATE){
8010644d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106450:	25 00 02 00 00       	and    $0x200,%eax
80106455:	85 c0                	test   %eax,%eax
80106457:	74 3b                	je     80106494 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106459:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010645c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106463:	00 
80106464:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010646b:	00 
8010646c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106473:	00 
80106474:	89 04 24             	mov    %eax,(%esp)
80106477:	e8 d3 fd ff ff       	call   8010624f <create>
8010647c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010647f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106483:	75 6a                	jne    801064ef <sys_open+0xe5>
      end_op();
80106485:	e8 03 d4 ff ff       	call   8010388d <end_op>
      return -1;
8010648a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010648f:	e9 18 01 00 00       	jmp    801065ac <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80106494:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106497:	89 04 24             	mov    %eax,(%esp)
8010649a:	e8 8e c2 ff ff       	call   8010272d <namei>
8010649f:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064a6:	75 0f                	jne    801064b7 <sys_open+0xad>
      end_op();
801064a8:	e8 e0 d3 ff ff       	call   8010388d <end_op>
      return -1;
801064ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064b2:	e9 f5 00 00 00       	jmp    801065ac <sys_open+0x1a2>
    }
    ilock(ip);
801064b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ba:	89 04 24             	mov    %eax,(%esp)
801064bd:	e8 00 b6 ff ff       	call   80101ac2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801064c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064c5:	8b 40 50             	mov    0x50(%eax),%eax
801064c8:	66 83 f8 01          	cmp    $0x1,%ax
801064cc:	75 21                	jne    801064ef <sys_open+0xe5>
801064ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064d1:	85 c0                	test   %eax,%eax
801064d3:	74 1a                	je     801064ef <sys_open+0xe5>
      iunlockput(ip);
801064d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d8:	89 04 24             	mov    %eax,(%esp)
801064db:	e8 e1 b7 ff ff       	call   80101cc1 <iunlockput>
      end_op();
801064e0:	e8 a8 d3 ff ff       	call   8010388d <end_op>
      return -1;
801064e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ea:	e9 bd 00 00 00       	jmp    801065ac <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801064ef:	e8 0e ac ff ff       	call   80101102 <filealloc>
801064f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064fb:	74 14                	je     80106511 <sys_open+0x107>
801064fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106500:	89 04 24             	mov    %eax,(%esp)
80106503:	e8 f8 f6 ff ff       	call   80105c00 <fdalloc>
80106508:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010650b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010650f:	79 28                	jns    80106539 <sys_open+0x12f>
    if(f)
80106511:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106515:	74 0b                	je     80106522 <sys_open+0x118>
      fileclose(f);
80106517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651a:	89 04 24             	mov    %eax,(%esp)
8010651d:	e8 88 ac ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
80106522:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106525:	89 04 24             	mov    %eax,(%esp)
80106528:	e8 94 b7 ff ff       	call   80101cc1 <iunlockput>
    end_op();
8010652d:	e8 5b d3 ff ff       	call   8010388d <end_op>
    return -1;
80106532:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106537:	eb 73                	jmp    801065ac <sys_open+0x1a2>
  }
  iunlock(ip);
80106539:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010653c:	89 04 24             	mov    %eax,(%esp)
8010653f:	e8 88 b6 ff ff       	call   80101bcc <iunlock>
  end_op();
80106544:	e8 44 d3 ff ff       	call   8010388d <end_op>

  f->type = FD_INODE;
80106549:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010654c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106555:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106558:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010655b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010655e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106565:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106568:	83 e0 01             	and    $0x1,%eax
8010656b:	85 c0                	test   %eax,%eax
8010656d:	0f 94 c0             	sete   %al
80106570:	88 c2                	mov    %al,%dl
80106572:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106575:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106578:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010657b:	83 e0 01             	and    $0x1,%eax
8010657e:	85 c0                	test   %eax,%eax
80106580:	75 0a                	jne    8010658c <sys_open+0x182>
80106582:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106585:	83 e0 02             	and    $0x2,%eax
80106588:	85 c0                	test   %eax,%eax
8010658a:	74 07                	je     80106593 <sys_open+0x189>
8010658c:	b8 01 00 00 00       	mov    $0x1,%eax
80106591:	eb 05                	jmp    80106598 <sys_open+0x18e>
80106593:	b8 00 00 00 00       	mov    $0x0,%eax
80106598:	88 c2                	mov    %al,%dl
8010659a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010659d:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
801065a0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801065a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a6:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
801065a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801065ac:	c9                   	leave  
801065ad:	c3                   	ret    

801065ae <sys_mkdir>:

int
sys_mkdir(void)
{
801065ae:	55                   	push   %ebp
801065af:	89 e5                	mov    %esp,%ebp
801065b1:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801065b4:	e8 52 d2 ff ff       	call   8010380b <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801065b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801065c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065c7:	e8 00 f5 ff ff       	call   80105acc <argstr>
801065cc:	85 c0                	test   %eax,%eax
801065ce:	78 2c                	js     801065fc <sys_mkdir+0x4e>
801065d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801065da:	00 
801065db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801065e2:	00 
801065e3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801065ea:	00 
801065eb:	89 04 24             	mov    %eax,(%esp)
801065ee:	e8 5c fc ff ff       	call   8010624f <create>
801065f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801065f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801065fa:	75 0c                	jne    80106608 <sys_mkdir+0x5a>
    end_op();
801065fc:	e8 8c d2 ff ff       	call   8010388d <end_op>
    return -1;
80106601:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106606:	eb 15                	jmp    8010661d <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010660b:	89 04 24             	mov    %eax,(%esp)
8010660e:	e8 ae b6 ff ff       	call   80101cc1 <iunlockput>
  end_op();
80106613:	e8 75 d2 ff ff       	call   8010388d <end_op>
  return 0;
80106618:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010661d:	c9                   	leave  
8010661e:	c3                   	ret    

8010661f <sys_mknod>:

int
sys_mknod(void)
{
8010661f:	55                   	push   %ebp
80106620:	89 e5                	mov    %esp,%ebp
80106622:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106625:	e8 e1 d1 ff ff       	call   8010380b <begin_op>
  if((argstr(0, &path)) < 0 ||
8010662a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010662d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106631:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106638:	e8 8f f4 ff ff       	call   80105acc <argstr>
8010663d:	85 c0                	test   %eax,%eax
8010663f:	78 5e                	js     8010669f <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106641:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106644:	89 44 24 04          	mov    %eax,0x4(%esp)
80106648:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010664f:	e8 e1 f3 ff ff       	call   80105a35 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106654:	85 c0                	test   %eax,%eax
80106656:	78 47                	js     8010669f <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106658:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010665b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010665f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106666:	e8 ca f3 ff ff       	call   80105a35 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010666b:	85 c0                	test   %eax,%eax
8010666d:	78 30                	js     8010669f <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
8010666f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106672:	0f bf c8             	movswl %ax,%ecx
80106675:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106678:	0f bf d0             	movswl %ax,%edx
8010667b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010667e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106682:	89 54 24 08          	mov    %edx,0x8(%esp)
80106686:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010668d:	00 
8010668e:	89 04 24             	mov    %eax,(%esp)
80106691:	e8 b9 fb ff ff       	call   8010624f <create>
80106696:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106699:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010669d:	75 0c                	jne    801066ab <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010669f:	e8 e9 d1 ff ff       	call   8010388d <end_op>
    return -1;
801066a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a9:	eb 15                	jmp    801066c0 <sys_mknod+0xa1>
  }
  iunlockput(ip);
801066ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ae:	89 04 24             	mov    %eax,(%esp)
801066b1:	e8 0b b6 ff ff       	call   80101cc1 <iunlockput>
  end_op();
801066b6:	e8 d2 d1 ff ff       	call   8010388d <end_op>
  return 0;
801066bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066c0:	c9                   	leave  
801066c1:	c3                   	ret    

801066c2 <sys_chdir>:

int
sys_chdir(void)
{
801066c2:	55                   	push   %ebp
801066c3:	89 e5                	mov    %esp,%ebp
801066c5:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801066c8:	e8 66 de ff ff       	call   80104533 <myproc>
801066cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801066d0:	e8 36 d1 ff ff       	call   8010380b <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801066d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801066dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066e3:	e8 e4 f3 ff ff       	call   80105acc <argstr>
801066e8:	85 c0                	test   %eax,%eax
801066ea:	78 14                	js     80106700 <sys_chdir+0x3e>
801066ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801066ef:	89 04 24             	mov    %eax,(%esp)
801066f2:	e8 36 c0 ff ff       	call   8010272d <namei>
801066f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066fe:	75 0c                	jne    8010670c <sys_chdir+0x4a>
    end_op();
80106700:	e8 88 d1 ff ff       	call   8010388d <end_op>
    return -1;
80106705:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010670a:	eb 5a                	jmp    80106766 <sys_chdir+0xa4>
  }
  ilock(ip);
8010670c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010670f:	89 04 24             	mov    %eax,(%esp)
80106712:	e8 ab b3 ff ff       	call   80101ac2 <ilock>
  if(ip->type != T_DIR){
80106717:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010671a:	8b 40 50             	mov    0x50(%eax),%eax
8010671d:	66 83 f8 01          	cmp    $0x1,%ax
80106721:	74 17                	je     8010673a <sys_chdir+0x78>
    iunlockput(ip);
80106723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106726:	89 04 24             	mov    %eax,(%esp)
80106729:	e8 93 b5 ff ff       	call   80101cc1 <iunlockput>
    end_op();
8010672e:	e8 5a d1 ff ff       	call   8010388d <end_op>
    return -1;
80106733:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106738:	eb 2c                	jmp    80106766 <sys_chdir+0xa4>
  }
  iunlock(ip);
8010673a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010673d:	89 04 24             	mov    %eax,(%esp)
80106740:	e8 87 b4 ff ff       	call   80101bcc <iunlock>
  iput(curproc->cwd);
80106745:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106748:	8b 40 68             	mov    0x68(%eax),%eax
8010674b:	89 04 24             	mov    %eax,(%esp)
8010674e:	e8 bd b4 ff ff       	call   80101c10 <iput>
  end_op();
80106753:	e8 35 d1 ff ff       	call   8010388d <end_op>
  curproc->cwd = ip;
80106758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010675e:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106761:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106766:	c9                   	leave  
80106767:	c3                   	ret    

80106768 <sys_exec>:

int
sys_exec(void)
{
80106768:	55                   	push   %ebp
80106769:	89 e5                	mov    %esp,%ebp
8010676b:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106771:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106774:	89 44 24 04          	mov    %eax,0x4(%esp)
80106778:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010677f:	e8 48 f3 ff ff       	call   80105acc <argstr>
80106784:	85 c0                	test   %eax,%eax
80106786:	78 1a                	js     801067a2 <sys_exec+0x3a>
80106788:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010678e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106792:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106799:	e8 97 f2 ff ff       	call   80105a35 <argint>
8010679e:	85 c0                	test   %eax,%eax
801067a0:	79 0a                	jns    801067ac <sys_exec+0x44>
    return -1;
801067a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067a7:	e9 c7 00 00 00       	jmp    80106873 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
801067ac:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801067b3:	00 
801067b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801067bb:	00 
801067bc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801067c2:	89 04 24             	mov    %eax,(%esp)
801067c5:	e8 38 ef ff ff       	call   80105702 <memset>
  for(i=0;; i++){
801067ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801067d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d4:	83 f8 1f             	cmp    $0x1f,%eax
801067d7:	76 0a                	jbe    801067e3 <sys_exec+0x7b>
      return -1;
801067d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067de:	e9 90 00 00 00       	jmp    80106873 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801067e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e6:	c1 e0 02             	shl    $0x2,%eax
801067e9:	89 c2                	mov    %eax,%edx
801067eb:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801067f1:	01 c2                	add    %eax,%edx
801067f3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801067f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801067fd:	89 14 24             	mov    %edx,(%esp)
80106800:	e8 8f f1 ff ff       	call   80105994 <fetchint>
80106805:	85 c0                	test   %eax,%eax
80106807:	79 07                	jns    80106810 <sys_exec+0xa8>
      return -1;
80106809:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010680e:	eb 63                	jmp    80106873 <sys_exec+0x10b>
    if(uarg == 0){
80106810:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106816:	85 c0                	test   %eax,%eax
80106818:	75 26                	jne    80106840 <sys_exec+0xd8>
      argv[i] = 0;
8010681a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681d:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106824:	00 00 00 00 
      break;
80106828:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106829:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010682c:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106832:	89 54 24 04          	mov    %edx,0x4(%esp)
80106836:	89 04 24             	mov    %eax,(%esp)
80106839:	e8 02 a4 ff ff       	call   80100c40 <exec>
8010683e:	eb 33                	jmp    80106873 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106840:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106846:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106849:	c1 e2 02             	shl    $0x2,%edx
8010684c:	01 c2                	add    %eax,%edx
8010684e:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106854:	89 54 24 04          	mov    %edx,0x4(%esp)
80106858:	89 04 24             	mov    %eax,(%esp)
8010685b:	e8 73 f1 ff ff       	call   801059d3 <fetchstr>
80106860:	85 c0                	test   %eax,%eax
80106862:	79 07                	jns    8010686b <sys_exec+0x103>
      return -1;
80106864:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106869:	eb 08                	jmp    80106873 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
8010686b:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010686e:	e9 5e ff ff ff       	jmp    801067d1 <sys_exec+0x69>
  return exec(path, argv);
}
80106873:	c9                   	leave  
80106874:	c3                   	ret    

80106875 <sys_pipe>:

int
sys_pipe(void)
{
80106875:	55                   	push   %ebp
80106876:	89 e5                	mov    %esp,%ebp
80106878:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010687b:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106882:	00 
80106883:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106886:	89 44 24 04          	mov    %eax,0x4(%esp)
8010688a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106891:	e8 cc f1 ff ff       	call   80105a62 <argptr>
80106896:	85 c0                	test   %eax,%eax
80106898:	79 0a                	jns    801068a4 <sys_pipe+0x2f>
    return -1;
8010689a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010689f:	e9 9a 00 00 00       	jmp    8010693e <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
801068a4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801068a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801068ab:	8d 45 e8             	lea    -0x18(%ebp),%eax
801068ae:	89 04 24             	mov    %eax,(%esp)
801068b1:	e8 d2 d7 ff ff       	call   80104088 <pipealloc>
801068b6:	85 c0                	test   %eax,%eax
801068b8:	79 07                	jns    801068c1 <sys_pipe+0x4c>
    return -1;
801068ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068bf:	eb 7d                	jmp    8010693e <sys_pipe+0xc9>
  fd0 = -1;
801068c1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801068c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068cb:	89 04 24             	mov    %eax,(%esp)
801068ce:	e8 2d f3 ff ff       	call   80105c00 <fdalloc>
801068d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068da:	78 14                	js     801068f0 <sys_pipe+0x7b>
801068dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068df:	89 04 24             	mov    %eax,(%esp)
801068e2:	e8 19 f3 ff ff       	call   80105c00 <fdalloc>
801068e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801068ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801068ee:	79 36                	jns    80106926 <sys_pipe+0xb1>
    if(fd0 >= 0)
801068f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068f4:	78 13                	js     80106909 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801068f6:	e8 38 dc ff ff       	call   80104533 <myproc>
801068fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801068fe:	83 c2 08             	add    $0x8,%edx
80106901:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106908:	00 
    fileclose(rf);
80106909:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010690c:	89 04 24             	mov    %eax,(%esp)
8010690f:	e8 96 a8 ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106914:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106917:	89 04 24             	mov    %eax,(%esp)
8010691a:	e8 8b a8 ff ff       	call   801011aa <fileclose>
    return -1;
8010691f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106924:	eb 18                	jmp    8010693e <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106926:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106929:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010692c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010692e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106931:	8d 50 04             	lea    0x4(%eax),%edx
80106934:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106937:	89 02                	mov    %eax,(%edx)
  return 0;
80106939:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010693e:	c9                   	leave  
8010693f:	c3                   	ret    

80106940 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106940:	55                   	push   %ebp
80106941:	89 e5                	mov    %esp,%ebp
80106943:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106946:	e8 e8 db ff ff       	call   80104533 <myproc>
8010694b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106951:	83 c0 18             	add    $0x18,%eax
80106954:	89 04 24             	mov    %eax,(%esp)
80106957:	e8 87 28 00 00       	call   801091e3 <find>
8010695c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
8010695f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106963:	78 51                	js     801069b6 <sys_fork+0x76>
    int before = get_curr_proc(x);
80106965:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106968:	89 04 24             	mov    %eax,(%esp)
8010696b:	e8 cb 29 00 00       	call   8010933b <get_curr_proc>
80106970:	89 45 f0             	mov    %eax,-0x10(%ebp)
    set_curr_proc(1, x);
80106973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106976:	89 44 24 04          	mov    %eax,0x4(%esp)
8010697a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106981:	e8 99 2c 00 00       	call   8010961f <set_curr_proc>
    int after = get_curr_proc(x);
80106986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106989:	89 04 24             	mov    %eax,(%esp)
8010698c:	e8 aa 29 00 00       	call   8010933b <get_curr_proc>
80106991:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(after == before){
80106994:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106997:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010699a:	75 1a                	jne    801069b6 <sys_fork+0x76>
      cstop_container_helper(myproc()->cont);
8010699c:	e8 92 db ff ff       	call   80104533 <myproc>
801069a1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801069a7:	89 04 24             	mov    %eax,(%esp)
801069aa:	e8 f1 e6 ff ff       	call   801050a0 <cstop_container_helper>
      return -1;
801069af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b4:	eb 05                	jmp    801069bb <sys_fork+0x7b>
    }
  }
  return fork();
801069b6:	e8 91 de ff ff       	call   8010484c <fork>
}
801069bb:	c9                   	leave  
801069bc:	c3                   	ret    

801069bd <sys_exit>:

int
sys_exit(void)
{
801069bd:	55                   	push   %ebp
801069be:	89 e5                	mov    %esp,%ebp
801069c0:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
801069c3:	e8 6b db ff ff       	call   80104533 <myproc>
801069c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801069ce:	83 c0 18             	add    $0x18,%eax
801069d1:	89 04 24             	mov    %eax,(%esp)
801069d4:	e8 0a 28 00 00       	call   801091e3 <find>
801069d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
801069dc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069e0:	78 13                	js     801069f5 <sys_exit+0x38>
    set_curr_proc(-1, x);
801069e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801069e9:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
801069f0:	e8 2a 2c 00 00       	call   8010961f <set_curr_proc>
  }
  exit();
801069f5:	e8 ca df ff ff       	call   801049c4 <exit>
  return 0;  // not reached
801069fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069ff:	c9                   	leave  
80106a00:	c3                   	ret    

80106a01 <sys_wait>:

int
sys_wait(void)
{
80106a01:	55                   	push   %ebp
80106a02:	89 e5                	mov    %esp,%ebp
80106a04:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106a07:	e8 fc e0 ff ff       	call   80104b08 <wait>
}
80106a0c:	c9                   	leave  
80106a0d:	c3                   	ret    

80106a0e <sys_kill>:

int
sys_kill(void)
{
80106a0e:	55                   	push   %ebp
80106a0f:	89 e5                	mov    %esp,%ebp
80106a11:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106a14:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106a17:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a1b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a22:	e8 0e f0 ff ff       	call   80105a35 <argint>
80106a27:	85 c0                	test   %eax,%eax
80106a29:	79 07                	jns    80106a32 <sys_kill+0x24>
    return -1;
80106a2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a30:	eb 0b                	jmp    80106a3d <sys_kill+0x2f>
  return kill(pid);
80106a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a35:	89 04 24             	mov    %eax,(%esp)
80106a38:	e8 a9 e4 ff ff       	call   80104ee6 <kill>
}
80106a3d:	c9                   	leave  
80106a3e:	c3                   	ret    

80106a3f <sys_getpid>:

int
sys_getpid(void)
{
80106a3f:	55                   	push   %ebp
80106a40:	89 e5                	mov    %esp,%ebp
80106a42:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106a45:	e8 e9 da ff ff       	call   80104533 <myproc>
80106a4a:	8b 40 10             	mov    0x10(%eax),%eax
}
80106a4d:	c9                   	leave  
80106a4e:	c3                   	ret    

80106a4f <sys_sbrk>:

int
sys_sbrk(void)
{
80106a4f:	55                   	push   %ebp
80106a50:	89 e5                	mov    %esp,%ebp
80106a52:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106a55:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a58:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a63:	e8 cd ef ff ff       	call   80105a35 <argint>
80106a68:	85 c0                	test   %eax,%eax
80106a6a:	79 07                	jns    80106a73 <sys_sbrk+0x24>
    return -1;
80106a6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a71:	eb 23                	jmp    80106a96 <sys_sbrk+0x47>
  addr = myproc()->sz;
80106a73:	e8 bb da ff ff       	call   80104533 <myproc>
80106a78:	8b 00                	mov    (%eax),%eax
80106a7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106a7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a80:	89 04 24             	mov    %eax,(%esp)
80106a83:	e8 26 dd ff ff       	call   801047ae <growproc>
80106a88:	85 c0                	test   %eax,%eax
80106a8a:	79 07                	jns    80106a93 <sys_sbrk+0x44>
    return -1;
80106a8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a91:	eb 03                	jmp    80106a96 <sys_sbrk+0x47>
  return addr;
80106a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106a96:	c9                   	leave  
80106a97:	c3                   	ret    

80106a98 <sys_sleep>:

int
sys_sleep(void)
{
80106a98:	55                   	push   %ebp
80106a99:	89 e5                	mov    %esp,%ebp
80106a9b:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106a9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106aac:	e8 84 ef ff ff       	call   80105a35 <argint>
80106ab1:	85 c0                	test   %eax,%eax
80106ab3:	79 07                	jns    80106abc <sys_sleep+0x24>
    return -1;
80106ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aba:	eb 6b                	jmp    80106b27 <sys_sleep+0x8f>
  acquire(&tickslock);
80106abc:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80106ac3:	e8 d7 e9 ff ff       	call   8010549f <acquire>
  ticks0 = ticks;
80106ac8:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80106acd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106ad0:	eb 33                	jmp    80106b05 <sys_sleep+0x6d>
    if(myproc()->killed){
80106ad2:	e8 5c da ff ff       	call   80104533 <myproc>
80106ad7:	8b 40 24             	mov    0x24(%eax),%eax
80106ada:	85 c0                	test   %eax,%eax
80106adc:	74 13                	je     80106af1 <sys_sleep+0x59>
      release(&tickslock);
80106ade:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80106ae5:	e8 1f ea ff ff       	call   80105509 <release>
      return -1;
80106aea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aef:	eb 36                	jmp    80106b27 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106af1:	c7 44 24 04 a0 83 11 	movl   $0x801183a0,0x4(%esp)
80106af8:	80 
80106af9:	c7 04 24 e0 8b 11 80 	movl   $0x80118be0,(%esp)
80106b00:	e8 df e2 ff ff       	call   80104de4 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106b05:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80106b0a:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106b0d:	89 c2                	mov    %eax,%edx
80106b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b12:	39 c2                	cmp    %eax,%edx
80106b14:	72 bc                	jb     80106ad2 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106b16:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80106b1d:	e8 e7 e9 ff ff       	call   80105509 <release>
  return 0;
80106b22:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b27:	c9                   	leave  
80106b28:	c3                   	ret    

80106b29 <sys_cstop>:

void sys_cstop(){
80106b29:	55                   	push   %ebp
80106b2a:	89 e5                	mov    %esp,%ebp
80106b2c:	53                   	push   %ebx
80106b2d:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
80106b30:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b33:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b3e:	e8 89 ef ff ff       	call   80105acc <argstr>

  if(myproc()->cont != NULL){
80106b43:	e8 eb d9 ff ff       	call   80104533 <myproc>
80106b48:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106b4e:	85 c0                	test   %eax,%eax
80106b50:	74 72                	je     80106bc4 <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
80106b52:	e8 dc d9 ff ff       	call   80104533 <myproc>
80106b57:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106b5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
80106b60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b63:	89 04 24             	mov    %eax,(%esp)
80106b66:	e8 ea ed ff ff       	call   80105955 <strlen>
80106b6b:	89 c3                	mov    %eax,%ebx
80106b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b70:	83 c0 18             	add    $0x18,%eax
80106b73:	89 04 24             	mov    %eax,(%esp)
80106b76:	e8 da ed ff ff       	call   80105955 <strlen>
80106b7b:	39 c3                	cmp    %eax,%ebx
80106b7d:	75 37                	jne    80106bb6 <sys_cstop+0x8d>
80106b7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b82:	89 04 24             	mov    %eax,(%esp)
80106b85:	e8 cb ed ff ff       	call   80105955 <strlen>
80106b8a:	89 c2                	mov    %eax,%edx
80106b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b8f:	8d 48 18             	lea    0x18(%eax),%ecx
80106b92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b95:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b99:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106b9d:	89 04 24             	mov    %eax,(%esp)
80106ba0:	e8 c5 ec ff ff       	call   8010586a <strncmp>
80106ba5:	85 c0                	test   %eax,%eax
80106ba7:	75 0d                	jne    80106bb6 <sys_cstop+0x8d>
      cstop_container_helper(cont);
80106ba9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bac:	89 04 24             	mov    %eax,(%esp)
80106baf:	e8 ec e4 ff ff       	call   801050a0 <cstop_container_helper>
80106bb4:	eb 19                	jmp    80106bcf <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106bb6:	c7 04 24 bc 9e 10 80 	movl   $0x80109ebc,(%esp)
80106bbd:	e8 ff 97 ff ff       	call   801003c1 <cprintf>
80106bc2:	eb 0b                	jmp    80106bcf <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bc7:	89 04 24             	mov    %eax,(%esp)
80106bca:	e8 38 e5 ff ff       	call   80105107 <cstop_helper>
  }

  //kill the processes with name as the id

}
80106bcf:	83 c4 24             	add    $0x24,%esp
80106bd2:	5b                   	pop    %ebx
80106bd3:	5d                   	pop    %ebp
80106bd4:	c3                   	ret    

80106bd5 <sys_set_root_inode>:

void sys_set_root_inode(void){
80106bd5:	55                   	push   %ebp
80106bd6:	89 e5                	mov    %esp,%ebp
80106bd8:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
80106bdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106bde:	89 44 24 04          	mov    %eax,0x4(%esp)
80106be2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106be9:	e8 de ee ff ff       	call   80105acc <argstr>

  set_root_inode(name);
80106bee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf1:	89 04 24             	mov    %eax,(%esp)
80106bf4:	e8 d6 24 00 00       	call   801090cf <set_root_inode>
  cprintf("success\n");
80106bf9:	c7 04 24 e0 9e 10 80 	movl   $0x80109ee0,(%esp)
80106c00:	e8 bc 97 ff ff       	call   801003c1 <cprintf>

}
80106c05:	c9                   	leave  
80106c06:	c3                   	ret    

80106c07 <sys_ps>:

void sys_ps(void){
80106c07:	55                   	push   %ebp
80106c08:	89 e5                	mov    %esp,%ebp
80106c0a:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
80106c0d:	e8 21 d9 ff ff       	call   80104533 <myproc>
80106c12:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106c18:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80106c1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c1f:	75 07                	jne    80106c28 <sys_ps+0x21>
    procdump();
80106c21:	e8 3b e3 ff ff       	call   80104f61 <procdump>
80106c26:	eb 0e                	jmp    80106c36 <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c2b:	83 c0 18             	add    $0x18,%eax
80106c2e:	89 04 24             	mov    %eax,(%esp)
80106c31:	e8 67 e5 ff ff       	call   8010519d <c_procdump>
  }
}
80106c36:	c9                   	leave  
80106c37:	c3                   	ret    

80106c38 <sys_container_init>:

void sys_container_init(){
80106c38:	55                   	push   %ebp
80106c39:	89 e5                	mov    %esp,%ebp
80106c3b:	83 ec 08             	sub    $0x8,%esp
  container_init();
80106c3e:	e8 7d 2a 00 00       	call   801096c0 <container_init>
}
80106c43:	c9                   	leave  
80106c44:	c3                   	ret    

80106c45 <sys_is_full>:

int sys_is_full(void){
80106c45:	55                   	push   %ebp
80106c46:	89 e5                	mov    %esp,%ebp
80106c48:	83 ec 08             	sub    $0x8,%esp
  return is_full();
80106c4b:	e8 43 25 00 00       	call   80109193 <is_full>
}
80106c50:	c9                   	leave  
80106c51:	c3                   	ret    

80106c52 <sys_find>:

int sys_find(void){
80106c52:	55                   	push   %ebp
80106c53:	89 e5                	mov    %esp,%ebp
80106c55:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106c58:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c66:	e8 61 ee ff ff       	call   80105acc <argstr>

  return find(name);
80106c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c6e:	89 04 24             	mov    %eax,(%esp)
80106c71:	e8 6d 25 00 00       	call   801091e3 <find>
}
80106c76:	c9                   	leave  
80106c77:	c3                   	ret    

80106c78 <sys_get_name>:

void sys_get_name(void){
80106c78:	55                   	push   %ebp
80106c79:	89 e5                	mov    %esp,%ebp
80106c7b:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
80106c7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c81:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c8c:	e8 a4 ed ff ff       	call   80105a35 <argint>
  argstr(1, &name);
80106c91:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c94:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c9f:	e8 28 ee ff ff       	call   80105acc <argstr>

  get_name(vc_num, name);
80106ca4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106caa:	89 54 24 04          	mov    %edx,0x4(%esp)
80106cae:	89 04 24             	mov    %eax,(%esp)
80106cb1:	e8 5a 24 00 00       	call   80109110 <get_name>
}
80106cb6:	c9                   	leave  
80106cb7:	c3                   	ret    

80106cb8 <sys_get_max_proc>:

int sys_get_max_proc(void){
80106cb8:	55                   	push   %ebp
80106cb9:	89 e5                	mov    %esp,%ebp
80106cbb:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106cbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106cc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ccc:	e8 64 ed ff ff       	call   80105a35 <argint>


  return get_max_proc(vc_num);  
80106cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cd4:	89 04 24             	mov    %eax,(%esp)
80106cd7:	e8 77 25 00 00       	call   80109253 <get_max_proc>
}
80106cdc:	c9                   	leave  
80106cdd:	c3                   	ret    

80106cde <sys_get_max_mem>:

int sys_get_max_mem(void){
80106cde:	55                   	push   %ebp
80106cdf:	89 e5                	mov    %esp,%ebp
80106ce1:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106ce4:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ceb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cf2:	e8 3e ed ff ff       	call   80105a35 <argint>


  return get_max_mem(vc_num);
80106cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cfa:	89 04 24             	mov    %eax,(%esp)
80106cfd:	e8 b9 25 00 00       	call   801092bb <get_max_mem>
}
80106d02:	c9                   	leave  
80106d03:	c3                   	ret    

80106d04 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106d04:	55                   	push   %ebp
80106d05:	89 e5                	mov    %esp,%ebp
80106d07:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d18:	e8 18 ed ff ff       	call   80105a35 <argint>


  return get_max_disk(vc_num);
80106d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d20:	89 04 24             	mov    %eax,(%esp)
80106d23:	e8 d3 25 00 00       	call   801092fb <get_max_disk>

}
80106d28:	c9                   	leave  
80106d29:	c3                   	ret    

80106d2a <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106d2a:	55                   	push   %ebp
80106d2b:	89 e5                	mov    %esp,%ebp
80106d2d:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d30:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d33:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d37:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d3e:	e8 f2 ec ff ff       	call   80105a35 <argint>


  return get_curr_proc(vc_num);
80106d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d46:	89 04 24             	mov    %eax,(%esp)
80106d49:	e8 ed 25 00 00       	call   8010933b <get_curr_proc>
}
80106d4e:	c9                   	leave  
80106d4f:	c3                   	ret    

80106d50 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106d50:	55                   	push   %ebp
80106d51:	89 e5                	mov    %esp,%ebp
80106d53:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d56:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d59:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d64:	e8 cc ec ff ff       	call   80105a35 <argint>


  return get_curr_mem(vc_num);
80106d69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d6c:	89 04 24             	mov    %eax,(%esp)
80106d6f:	e8 07 26 00 00       	call   8010937b <get_curr_mem>
}
80106d74:	c9                   	leave  
80106d75:	c3                   	ret    

80106d76 <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106d76:	55                   	push   %ebp
80106d77:	89 e5                	mov    %esp,%ebp
80106d79:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106d7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d8a:	e8 a6 ec ff ff       	call   80105a35 <argint>


  return get_curr_disk(vc_num);
80106d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d92:	89 04 24             	mov    %eax,(%esp)
80106d95:	e8 21 26 00 00       	call   801093bb <get_curr_disk>
}
80106d9a:	c9                   	leave  
80106d9b:	c3                   	ret    

80106d9c <sys_set_name>:

void sys_set_name(void){
80106d9c:	55                   	push   %ebp
80106d9d:	89 e5                	mov    %esp,%ebp
80106d9f:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106da2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106da5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106da9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106db0:	e8 17 ed ff ff       	call   80105acc <argstr>

  int vc_num;
  argint(1, &vc_num);
80106db5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106db8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dbc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106dc3:	e8 6d ec ff ff       	call   80105a35 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80106dc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dce:	89 54 24 04          	mov    %edx,0x4(%esp)
80106dd2:	89 04 24             	mov    %eax,(%esp)
80106dd5:	e8 21 26 00 00       	call   801093fb <set_name>
  //cprintf("Done setting name.\n");
}
80106dda:	c9                   	leave  
80106ddb:	c3                   	ret    

80106ddc <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80106ddc:	55                   	push   %ebp
80106ddd:	89 e5                	mov    %esp,%ebp
80106ddf:	53                   	push   %ebx
80106de0:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106de3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106de6:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106df1:	e8 3f ec ff ff       	call   80105a35 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106df6:	e8 38 d7 ff ff       	call   80104533 <myproc>
80106dfb:	89 c3                	mov    %eax,%ebx
80106dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e00:	89 04 24             	mov    %eax,(%esp)
80106e03:	e8 8b 24 00 00       	call   80109293 <get_container>
80106e08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80106e0e:	83 c4 24             	add    $0x24,%esp
80106e11:	5b                   	pop    %ebx
80106e12:	5d                   	pop    %ebp
80106e13:	c3                   	ret    

80106e14 <sys_set_max_mem>:

void sys_set_max_mem(void){
80106e14:	55                   	push   %ebp
80106e15:	89 e5                	mov    %esp,%ebp
80106e17:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106e1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e28:	e8 08 ec ff ff       	call   80105a35 <argint>

  int vc_num;
  argint(1, &vc_num);
80106e2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e30:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e3b:	e8 f5 eb ff ff       	call   80105a35 <argint>

  set_max_mem(mem, vc_num);
80106e40:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106e43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e46:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e4a:	89 04 24             	mov    %eax,(%esp)
80106e4d:	e8 e0 25 00 00       	call   80109432 <set_max_mem>
}
80106e52:	c9                   	leave  
80106e53:	c3                   	ret    

80106e54 <sys_set_max_disk>:

void sys_set_max_disk(void){
80106e54:	55                   	push   %ebp
80106e55:	89 e5                	mov    %esp,%ebp
80106e57:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106e5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e68:	e8 c8 eb ff ff       	call   80105a35 <argint>

  int vc_num;
  argint(1, &vc_num);
80106e6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e70:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e7b:	e8 b5 eb ff ff       	call   80105a35 <argint>

  set_max_disk(disk, vc_num);
80106e80:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e86:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e8a:	89 04 24             	mov    %eax,(%esp)
80106e8d:	e8 c5 25 00 00       	call   80109457 <set_max_disk>
}
80106e92:	c9                   	leave  
80106e93:	c3                   	ret    

80106e94 <sys_set_max_proc>:

void sys_set_max_proc(void){
80106e94:	55                   	push   %ebp
80106e95:	89 e5                	mov    %esp,%ebp
80106e97:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106e9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ea1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ea8:	e8 88 eb ff ff       	call   80105a35 <argint>

  int vc_num;
  argint(1, &vc_num);
80106ead:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106eb4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106ebb:	e8 75 eb ff ff       	call   80105a35 <argint>

  set_max_proc(proc, vc_num);
80106ec0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ec3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ec6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106eca:	89 04 24             	mov    %eax,(%esp)
80106ecd:	e8 ab 25 00 00       	call   8010947d <set_max_proc>
}
80106ed2:	c9                   	leave  
80106ed3:	c3                   	ret    

80106ed4 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
80106ed4:	55                   	push   %ebp
80106ed5:	89 e5                	mov    %esp,%ebp
80106ed7:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106eda:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106edd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ee1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ee8:	e8 48 eb ff ff       	call   80105a35 <argint>

  int vc_num;
  argint(1, &vc_num);
80106eed:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ef4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106efb:	e8 35 eb ff ff       	call   80105a35 <argint>

  set_curr_mem(mem, vc_num);
80106f00:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f06:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f0a:	89 04 24             	mov    %eax,(%esp)
80106f0d:	e8 91 25 00 00       	call   801094a3 <set_curr_mem>
}
80106f12:	c9                   	leave  
80106f13:	c3                   	ret    

80106f14 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
80106f14:	55                   	push   %ebp
80106f15:	89 e5                	mov    %esp,%ebp
80106f17:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106f1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f28:	e8 08 eb ff ff       	call   80105a35 <argint>

  int vc_num;
  argint(1, &vc_num);
80106f2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f30:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f3b:	e8 f5 ea ff ff       	call   80105a35 <argint>

  set_curr_mem(mem, vc_num);
80106f40:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f46:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f4a:	89 04 24             	mov    %eax,(%esp)
80106f4d:	e8 51 25 00 00       	call   801094a3 <set_curr_mem>
}
80106f52:	c9                   	leave  
80106f53:	c3                   	ret    

80106f54 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80106f54:	55                   	push   %ebp
80106f55:	89 e5                	mov    %esp,%ebp
80106f57:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
80106f5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f68:	e8 c8 ea ff ff       	call   80105a35 <argint>

  int vc_num;
  argint(1, &vc_num);
80106f6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f70:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f74:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f7b:	e8 b5 ea ff ff       	call   80105a35 <argint>

  set_curr_disk(disk, vc_num);
80106f80:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f86:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f8a:	89 04 24             	mov    %eax,(%esp)
80106f8d:	e8 e6 25 00 00       	call   80109578 <set_curr_disk>
}
80106f92:	c9                   	leave  
80106f93:	c3                   	ret    

80106f94 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80106f94:	55                   	push   %ebp
80106f95:	89 e5                	mov    %esp,%ebp
80106f97:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
80106f9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fa8:	e8 88 ea ff ff       	call   80105a35 <argint>

  int vc_num;
  argint(1, &vc_num);
80106fad:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fb4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106fbb:	e8 75 ea ff ff       	call   80105a35 <argint>

  set_curr_proc(proc, vc_num);
80106fc0:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc6:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fca:	89 04 24             	mov    %eax,(%esp)
80106fcd:	e8 4d 26 00 00       	call   8010961f <set_curr_proc>
}
80106fd2:	c9                   	leave  
80106fd3:	c3                   	ret    

80106fd4 <sys_container_reset>:

void sys_container_reset(void){
80106fd4:	55                   	push   %ebp
80106fd5:	89 e5                	mov    %esp,%ebp
80106fd7:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(1, &vc_num);
80106fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fe1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106fe8:	e8 48 ea ff ff       	call   80105a35 <argint>
  container_reset(vc_num);
80106fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff0:	89 04 24             	mov    %eax,(%esp)
80106ff3:	e8 dd 27 00 00       	call   801097d5 <container_reset>
}
80106ff8:	c9                   	leave  
80106ff9:	c3                   	ret    

80106ffa <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106ffa:	55                   	push   %ebp
80106ffb:	89 e5                	mov    %esp,%ebp
80106ffd:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80107000:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80107007:	e8 93 e4 ff ff       	call   8010549f <acquire>
  xticks = ticks;
8010700c:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80107011:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107014:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
8010701b:	e8 e9 e4 ff ff       	call   80105509 <release>
  return xticks;
80107020:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107023:	c9                   	leave  
80107024:	c3                   	ret    

80107025 <sys_getticks>:

int
sys_getticks(void){
80107025:	55                   	push   %ebp
80107026:	89 e5                	mov    %esp,%ebp
80107028:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
8010702b:	e8 03 d5 ff ff       	call   80104533 <myproc>
80107030:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80107033:	c9                   	leave  
80107034:	c3                   	ret    

80107035 <sys_max_containers>:

int sys_max_containers(void){
80107035:	55                   	push   %ebp
80107036:	89 e5                	mov    %esp,%ebp
80107038:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
8010703b:	e8 76 26 00 00       	call   801096b6 <max_containers>
}
80107040:	c9                   	leave  
80107041:	c3                   	ret    

80107042 <sys_df>:


void sys_df(void){
80107042:	55                   	push   %ebp
80107043:	89 e5                	mov    %esp,%ebp
80107045:	53                   	push   %ebx
80107046:	83 ec 54             	sub    $0x54,%esp
  struct container* cont = myproc()->cont;
80107049:	e8 e5 d4 ff ff       	call   80104533 <myproc>
8010704e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107054:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct superblock sb;
  readsb(1, &sb);
80107057:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010705a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010705e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107065:	e8 56 a4 ff ff       	call   801014c0 <readsb>

  cprintf("nblocks: %d\n", sb.nblocks);
8010706a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010706d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107071:	c7 04 24 e9 9e 10 80 	movl   $0x80109ee9,(%esp)
80107078:	e8 44 93 ff ff       	call   801003c1 <cprintf>
  cprintf("nblocks: %d\n", FSSIZE);
8010707d:	c7 44 24 04 20 4e 00 	movl   $0x4e20,0x4(%esp)
80107084:	00 
80107085:	c7 04 24 e9 9e 10 80 	movl   $0x80109ee9,(%esp)
8010708c:	e8 30 93 ff ff       	call   801003c1 <cprintf>
  int used = 0;
80107091:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
80107098:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010709c:	75 52                	jne    801070f0 <sys_df+0xae>
    int max = max_containers();
8010709e:	e8 13 26 00 00       	call   801096b6 <max_containers>
801070a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
801070a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801070ad:	eb 1d                	jmp    801070cc <sys_df+0x8a>
      used = used + (int)(get_curr_disk(i) / 1024);
801070af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070b2:	89 04 24             	mov    %eax,(%esp)
801070b5:	e8 01 23 00 00       	call   801093bb <get_curr_disk>
801070ba:	85 c0                	test   %eax,%eax
801070bc:	79 05                	jns    801070c3 <sys_df+0x81>
801070be:	05 ff 03 00 00       	add    $0x3ff,%eax
801070c3:	c1 f8 0a             	sar    $0xa,%eax
801070c6:	01 45 f4             	add    %eax,-0xc(%ebp)
  cprintf("nblocks: %d\n", FSSIZE);
  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
801070c9:	ff 45 f0             	incl   -0x10(%ebp)
801070cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070cf:	3b 45 e8             	cmp    -0x18(%ebp),%eax
801070d2:	7c db                	jl     801070af <sys_df+0x6d>
      used = used + (int)(get_curr_disk(i) / 1024);
    }
    cprintf("Total Disk Used: ~%d / Total Disk Available: %d\n", used, sb.nblocks);
801070d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
801070d7:	89 44 24 08          	mov    %eax,0x8(%esp)
801070db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070de:	89 44 24 04          	mov    %eax,0x4(%esp)
801070e2:	c7 04 24 f8 9e 10 80 	movl   $0x80109ef8,(%esp)
801070e9:	e8 d3 92 ff ff       	call   801003c1 <cprintf>
801070ee:	eb 5e                	jmp    8010714e <sys_df+0x10c>
  }
  else{
    int x = find(cont->name);
801070f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801070f3:	83 c0 18             	add    $0x18,%eax
801070f6:	89 04 24             	mov    %eax,(%esp)
801070f9:	e8 e5 20 00 00       	call   801091e3 <find>
801070fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
80107101:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107104:	89 04 24             	mov    %eax,(%esp)
80107107:	e8 af 22 00 00       	call   801093bb <get_curr_disk>
8010710c:	85 c0                	test   %eax,%eax
8010710e:	79 05                	jns    80107115 <sys_df+0xd3>
80107110:	05 ff 03 00 00       	add    $0x3ff,%eax
80107115:	c1 f8 0a             	sar    $0xa,%eax
80107118:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("Disk Used: ~%d -- %d  / Disk Available: %d\n", used, get_curr_disk(x),  get_max_disk(x));
8010711b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010711e:	89 04 24             	mov    %eax,(%esp)
80107121:	e8 d5 21 00 00       	call   801092fb <get_max_disk>
80107126:	89 c3                	mov    %eax,%ebx
80107128:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010712b:	89 04 24             	mov    %eax,(%esp)
8010712e:	e8 88 22 00 00       	call   801093bb <get_curr_disk>
80107133:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
80107137:	89 44 24 08          	mov    %eax,0x8(%esp)
8010713b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010713e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107142:	c7 04 24 2c 9f 10 80 	movl   $0x80109f2c,(%esp)
80107149:	e8 73 92 ff ff       	call   801003c1 <cprintf>
  }
}
8010714e:	83 c4 54             	add    $0x54,%esp
80107151:	5b                   	pop    %ebx
80107152:	5d                   	pop    %ebp
80107153:	c3                   	ret    

80107154 <sys_pause>:

void
sys_pause(void){
80107154:	55                   	push   %ebp
80107155:	89 e5                	mov    %esp,%ebp
80107157:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
8010715a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010715d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107161:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107168:	e8 5f e9 ff ff       	call   80105acc <argstr>
  pause(name);
8010716d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107170:	89 04 24             	mov    %eax,(%esp)
80107173:	e8 f7 e0 ff ff       	call   8010526f <pause>
}
80107178:	c9                   	leave  
80107179:	c3                   	ret    

8010717a <sys_resume>:

void
sys_resume(void){
8010717a:	55                   	push   %ebp
8010717b:	89 e5                	mov    %esp,%ebp
8010717d:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
80107180:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107183:	89 44 24 04          	mov    %eax,0x4(%esp)
80107187:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010718e:	e8 39 e9 ff ff       	call   80105acc <argstr>
  resume(name);
80107193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107196:	89 04 24             	mov    %eax,(%esp)
80107199:	e8 34 e1 ff ff       	call   801052d2 <resume>
}
8010719e:	c9                   	leave  
8010719f:	c3                   	ret    

801071a0 <sys_tmem>:

int
sys_tmem(void){
801071a0:	55                   	push   %ebp
801071a1:	89 e5                	mov    %esp,%ebp
801071a3:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
801071a6:	e8 88 d3 ff ff       	call   80104533 <myproc>
801071ab:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801071b1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
801071b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071b8:	75 07                	jne    801071c1 <sys_tmem+0x21>
    return mem_usage();
801071ba:	e8 9d bd ff ff       	call   80102f5c <mem_usage>
801071bf:	eb 16                	jmp    801071d7 <sys_tmem+0x37>
  }
  return get_curr_mem(find(cont->name));
801071c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c4:	83 c0 18             	add    $0x18,%eax
801071c7:	89 04 24             	mov    %eax,(%esp)
801071ca:	e8 14 20 00 00       	call   801091e3 <find>
801071cf:	89 04 24             	mov    %eax,(%esp)
801071d2:	e8 a4 21 00 00       	call   8010937b <get_curr_mem>
}
801071d7:	c9                   	leave  
801071d8:	c3                   	ret    

801071d9 <sys_amem>:

int
sys_amem(void){
801071d9:	55                   	push   %ebp
801071da:	89 e5                	mov    %esp,%ebp
801071dc:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
801071df:	e8 4f d3 ff ff       	call   80104533 <myproc>
801071e4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801071ea:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
801071ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801071f1:	75 07                	jne    801071fa <sys_amem+0x21>
    return mem_avail();
801071f3:	e8 6e bd ff ff       	call   80102f66 <mem_avail>
801071f8:	eb 16                	jmp    80107210 <sys_amem+0x37>
  }
  return get_max_mem(find(cont->name));
801071fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fd:	83 c0 18             	add    $0x18,%eax
80107200:	89 04 24             	mov    %eax,(%esp)
80107203:	e8 db 1f 00 00       	call   801091e3 <find>
80107208:	89 04 24             	mov    %eax,(%esp)
8010720b:	e8 ab 20 00 00       	call   801092bb <get_max_mem>
}
80107210:	c9                   	leave  
80107211:	c3                   	ret    

80107212 <sys_c_ps>:

void sys_c_ps(void){
80107212:	55                   	push   %ebp
80107213:	89 e5                	mov    %esp,%ebp
80107215:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
80107218:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010721b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010721f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107226:	e8 a1 e8 ff ff       	call   80105acc <argstr>
  c_procdump(name);
8010722b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010722e:	89 04 24             	mov    %eax,(%esp)
80107231:	e8 67 df ff ff       	call   8010519d <c_procdump>
}
80107236:	c9                   	leave  
80107237:	c3                   	ret    

80107238 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107238:	1e                   	push   %ds
  pushl %es
80107239:	06                   	push   %es
  pushl %fs
8010723a:	0f a0                	push   %fs
  pushl %gs
8010723c:	0f a8                	push   %gs
  pushal
8010723e:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010723f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107243:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107245:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80107247:	54                   	push   %esp
  call trap
80107248:	e8 c0 01 00 00       	call   8010740d <trap>
  addl $4, %esp
8010724d:	83 c4 04             	add    $0x4,%esp

80107250 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107250:	61                   	popa   
  popl %gs
80107251:	0f a9                	pop    %gs
  popl %fs
80107253:	0f a1                	pop    %fs
  popl %es
80107255:	07                   	pop    %es
  popl %ds
80107256:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107257:	83 c4 08             	add    $0x8,%esp
  iret
8010725a:	cf                   	iret   
	...

8010725c <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
8010725c:	55                   	push   %ebp
8010725d:	89 e5                	mov    %esp,%ebp
8010725f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107262:	8b 45 0c             	mov    0xc(%ebp),%eax
80107265:	48                   	dec    %eax
80107266:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010726a:	8b 45 08             	mov    0x8(%ebp),%eax
8010726d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107271:	8b 45 08             	mov    0x8(%ebp),%eax
80107274:	c1 e8 10             	shr    $0x10,%eax
80107277:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010727b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010727e:	0f 01 18             	lidtl  (%eax)
}
80107281:	c9                   	leave  
80107282:	c3                   	ret    

80107283 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107283:	55                   	push   %ebp
80107284:	89 e5                	mov    %esp,%ebp
80107286:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107289:	0f 20 d0             	mov    %cr2,%eax
8010728c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010728f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107292:	c9                   	leave  
80107293:	c3                   	ret    

80107294 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107294:	55                   	push   %ebp
80107295:	89 e5                	mov    %esp,%ebp
80107297:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010729a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801072a1:	e9 b8 00 00 00       	jmp    8010735e <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801072a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072a9:	8b 04 85 14 d1 10 80 	mov    -0x7fef2eec(,%eax,4),%eax
801072b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801072b3:	66 89 04 d5 e0 83 11 	mov    %ax,-0x7fee7c20(,%edx,8)
801072ba:	80 
801072bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072be:	66 c7 04 c5 e2 83 11 	movw   $0x8,-0x7fee7c1e(,%eax,8)
801072c5:	80 08 00 
801072c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072cb:	8a 14 c5 e4 83 11 80 	mov    -0x7fee7c1c(,%eax,8),%dl
801072d2:	83 e2 e0             	and    $0xffffffe0,%edx
801072d5:	88 14 c5 e4 83 11 80 	mov    %dl,-0x7fee7c1c(,%eax,8)
801072dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072df:	8a 14 c5 e4 83 11 80 	mov    -0x7fee7c1c(,%eax,8),%dl
801072e6:	83 e2 1f             	and    $0x1f,%edx
801072e9:	88 14 c5 e4 83 11 80 	mov    %dl,-0x7fee7c1c(,%eax,8)
801072f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072f3:	8a 14 c5 e5 83 11 80 	mov    -0x7fee7c1b(,%eax,8),%dl
801072fa:	83 e2 f0             	and    $0xfffffff0,%edx
801072fd:	83 ca 0e             	or     $0xe,%edx
80107300:	88 14 c5 e5 83 11 80 	mov    %dl,-0x7fee7c1b(,%eax,8)
80107307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010730a:	8a 14 c5 e5 83 11 80 	mov    -0x7fee7c1b(,%eax,8),%dl
80107311:	83 e2 ef             	and    $0xffffffef,%edx
80107314:	88 14 c5 e5 83 11 80 	mov    %dl,-0x7fee7c1b(,%eax,8)
8010731b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010731e:	8a 14 c5 e5 83 11 80 	mov    -0x7fee7c1b(,%eax,8),%dl
80107325:	83 e2 9f             	and    $0xffffff9f,%edx
80107328:	88 14 c5 e5 83 11 80 	mov    %dl,-0x7fee7c1b(,%eax,8)
8010732f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107332:	8a 14 c5 e5 83 11 80 	mov    -0x7fee7c1b(,%eax,8),%dl
80107339:	83 ca 80             	or     $0xffffff80,%edx
8010733c:	88 14 c5 e5 83 11 80 	mov    %dl,-0x7fee7c1b(,%eax,8)
80107343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107346:	8b 04 85 14 d1 10 80 	mov    -0x7fef2eec(,%eax,4),%eax
8010734d:	c1 e8 10             	shr    $0x10,%eax
80107350:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107353:	66 89 04 d5 e6 83 11 	mov    %ax,-0x7fee7c1a(,%edx,8)
8010735a:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010735b:	ff 45 f4             	incl   -0xc(%ebp)
8010735e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107365:	0f 8e 3b ff ff ff    	jle    801072a6 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010736b:	a1 14 d2 10 80       	mov    0x8010d214,%eax
80107370:	66 a3 e0 85 11 80    	mov    %ax,0x801185e0
80107376:	66 c7 05 e2 85 11 80 	movw   $0x8,0x801185e2
8010737d:	08 00 
8010737f:	a0 e4 85 11 80       	mov    0x801185e4,%al
80107384:	83 e0 e0             	and    $0xffffffe0,%eax
80107387:	a2 e4 85 11 80       	mov    %al,0x801185e4
8010738c:	a0 e4 85 11 80       	mov    0x801185e4,%al
80107391:	83 e0 1f             	and    $0x1f,%eax
80107394:	a2 e4 85 11 80       	mov    %al,0x801185e4
80107399:	a0 e5 85 11 80       	mov    0x801185e5,%al
8010739e:	83 c8 0f             	or     $0xf,%eax
801073a1:	a2 e5 85 11 80       	mov    %al,0x801185e5
801073a6:	a0 e5 85 11 80       	mov    0x801185e5,%al
801073ab:	83 e0 ef             	and    $0xffffffef,%eax
801073ae:	a2 e5 85 11 80       	mov    %al,0x801185e5
801073b3:	a0 e5 85 11 80       	mov    0x801185e5,%al
801073b8:	83 c8 60             	or     $0x60,%eax
801073bb:	a2 e5 85 11 80       	mov    %al,0x801185e5
801073c0:	a0 e5 85 11 80       	mov    0x801185e5,%al
801073c5:	83 c8 80             	or     $0xffffff80,%eax
801073c8:	a2 e5 85 11 80       	mov    %al,0x801185e5
801073cd:	a1 14 d2 10 80       	mov    0x8010d214,%eax
801073d2:	c1 e8 10             	shr    $0x10,%eax
801073d5:	66 a3 e6 85 11 80    	mov    %ax,0x801185e6

  initlock(&tickslock, "time");
801073db:	c7 44 24 04 58 9f 10 	movl   $0x80109f58,0x4(%esp)
801073e2:	80 
801073e3:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
801073ea:	e8 8f e0 ff ff       	call   8010547e <initlock>
}
801073ef:	c9                   	leave  
801073f0:	c3                   	ret    

801073f1 <idtinit>:

void
idtinit(void)
{
801073f1:	55                   	push   %ebp
801073f2:	89 e5                	mov    %esp,%ebp
801073f4:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801073f7:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801073fe:	00 
801073ff:	c7 04 24 e0 83 11 80 	movl   $0x801183e0,(%esp)
80107406:	e8 51 fe ff ff       	call   8010725c <lidt>
}
8010740b:	c9                   	leave  
8010740c:	c3                   	ret    

8010740d <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010740d:	55                   	push   %ebp
8010740e:	89 e5                	mov    %esp,%ebp
80107410:	57                   	push   %edi
80107411:	56                   	push   %esi
80107412:	53                   	push   %ebx
80107413:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80107416:	8b 45 08             	mov    0x8(%ebp),%eax
80107419:	8b 40 30             	mov    0x30(%eax),%eax
8010741c:	83 f8 40             	cmp    $0x40,%eax
8010741f:	75 3c                	jne    8010745d <trap+0x50>
    if(myproc()->killed)
80107421:	e8 0d d1 ff ff       	call   80104533 <myproc>
80107426:	8b 40 24             	mov    0x24(%eax),%eax
80107429:	85 c0                	test   %eax,%eax
8010742b:	74 05                	je     80107432 <trap+0x25>
      exit();
8010742d:	e8 92 d5 ff ff       	call   801049c4 <exit>
    myproc()->tf = tf;
80107432:	e8 fc d0 ff ff       	call   80104533 <myproc>
80107437:	8b 55 08             	mov    0x8(%ebp),%edx
8010743a:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010743d:	e8 c1 e6 ff ff       	call   80105b03 <syscall>
    if(myproc()->killed)
80107442:	e8 ec d0 ff ff       	call   80104533 <myproc>
80107447:	8b 40 24             	mov    0x24(%eax),%eax
8010744a:	85 c0                	test   %eax,%eax
8010744c:	74 0a                	je     80107458 <trap+0x4b>
      exit();
8010744e:	e8 71 d5 ff ff       	call   801049c4 <exit>
    return;
80107453:	e9 30 02 00 00       	jmp    80107688 <trap+0x27b>
80107458:	e9 2b 02 00 00       	jmp    80107688 <trap+0x27b>
  }

  switch(tf->trapno){
8010745d:	8b 45 08             	mov    0x8(%ebp),%eax
80107460:	8b 40 30             	mov    0x30(%eax),%eax
80107463:	83 e8 20             	sub    $0x20,%eax
80107466:	83 f8 1f             	cmp    $0x1f,%eax
80107469:	0f 87 cb 00 00 00    	ja     8010753a <trap+0x12d>
8010746f:	8b 04 85 00 a0 10 80 	mov    -0x7fef6000(,%eax,4),%eax
80107476:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80107478:	e8 ed cf ff ff       	call   8010446a <cpuid>
8010747d:	85 c0                	test   %eax,%eax
8010747f:	75 2f                	jne    801074b0 <trap+0xa3>
      acquire(&tickslock);
80107481:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
80107488:	e8 12 e0 ff ff       	call   8010549f <acquire>
      ticks++;
8010748d:	a1 e0 8b 11 80       	mov    0x80118be0,%eax
80107492:	40                   	inc    %eax
80107493:	a3 e0 8b 11 80       	mov    %eax,0x80118be0
      wakeup(&ticks);
80107498:	c7 04 24 e0 8b 11 80 	movl   $0x80118be0,(%esp)
8010749f:	e8 17 da ff ff       	call   80104ebb <wakeup>
      release(&tickslock);
801074a4:	c7 04 24 a0 83 11 80 	movl   $0x801183a0,(%esp)
801074ab:	e8 59 e0 ff ff       	call   80105509 <release>
    }
    p = myproc();
801074b0:	e8 7e d0 ff ff       	call   80104533 <myproc>
801074b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801074b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801074bc:	74 0f                	je     801074cd <trap+0xc0>
      p->ticks++;
801074be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801074c1:	8b 40 7c             	mov    0x7c(%eax),%eax
801074c4:	8d 50 01             	lea    0x1(%eax),%edx
801074c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801074ca:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801074cd:	e8 11 be ff ff       	call   801032e3 <lapiceoi>
    break;
801074d2:	e9 35 01 00 00       	jmp    8010760c <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801074d7:	e8 7e b5 ff ff       	call   80102a5a <ideintr>
    lapiceoi();
801074dc:	e8 02 be ff ff       	call   801032e3 <lapiceoi>
    break;
801074e1:	e9 26 01 00 00       	jmp    8010760c <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801074e6:	e8 0f bc ff ff       	call   801030fa <kbdintr>
    lapiceoi();
801074eb:	e8 f3 bd ff ff       	call   801032e3 <lapiceoi>
    break;
801074f0:	e9 17 01 00 00       	jmp    8010760c <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801074f5:	e8 6f 03 00 00       	call   80107869 <uartintr>
    lapiceoi();
801074fa:	e8 e4 bd ff ff       	call   801032e3 <lapiceoi>
    break;
801074ff:	e9 08 01 00 00       	jmp    8010760c <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107504:	8b 45 08             	mov    0x8(%ebp),%eax
80107507:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010750a:	8b 45 08             	mov    0x8(%ebp),%eax
8010750d:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107510:	0f b7 d8             	movzwl %ax,%ebx
80107513:	e8 52 cf ff ff       	call   8010446a <cpuid>
80107518:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010751c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107520:	89 44 24 04          	mov    %eax,0x4(%esp)
80107524:	c7 04 24 60 9f 10 80 	movl   $0x80109f60,(%esp)
8010752b:	e8 91 8e ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80107530:	e8 ae bd ff ff       	call   801032e3 <lapiceoi>
    break;
80107535:	e9 d2 00 00 00       	jmp    8010760c <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010753a:	e8 f4 cf ff ff       	call   80104533 <myproc>
8010753f:	85 c0                	test   %eax,%eax
80107541:	74 10                	je     80107553 <trap+0x146>
80107543:	8b 45 08             	mov    0x8(%ebp),%eax
80107546:	8b 40 3c             	mov    0x3c(%eax),%eax
80107549:	0f b7 c0             	movzwl %ax,%eax
8010754c:	83 e0 03             	and    $0x3,%eax
8010754f:	85 c0                	test   %eax,%eax
80107551:	75 40                	jne    80107593 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107553:	e8 2b fd ff ff       	call   80107283 <rcr2>
80107558:	89 c3                	mov    %eax,%ebx
8010755a:	8b 45 08             	mov    0x8(%ebp),%eax
8010755d:	8b 70 38             	mov    0x38(%eax),%esi
80107560:	e8 05 cf ff ff       	call   8010446a <cpuid>
80107565:	8b 55 08             	mov    0x8(%ebp),%edx
80107568:	8b 52 30             	mov    0x30(%edx),%edx
8010756b:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010756f:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107573:	89 44 24 08          	mov    %eax,0x8(%esp)
80107577:	89 54 24 04          	mov    %edx,0x4(%esp)
8010757b:	c7 04 24 84 9f 10 80 	movl   $0x80109f84,(%esp)
80107582:	e8 3a 8e ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80107587:	c7 04 24 b6 9f 10 80 	movl   $0x80109fb6,(%esp)
8010758e:	e8 c1 8f ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107593:	e8 eb fc ff ff       	call   80107283 <rcr2>
80107598:	89 c6                	mov    %eax,%esi
8010759a:	8b 45 08             	mov    0x8(%ebp),%eax
8010759d:	8b 40 38             	mov    0x38(%eax),%eax
801075a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801075a3:	e8 c2 ce ff ff       	call   8010446a <cpuid>
801075a8:	89 c3                	mov    %eax,%ebx
801075aa:	8b 45 08             	mov    0x8(%ebp),%eax
801075ad:	8b 78 34             	mov    0x34(%eax),%edi
801075b0:	89 7d d0             	mov    %edi,-0x30(%ebp)
801075b3:	8b 45 08             	mov    0x8(%ebp),%eax
801075b6:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801075b9:	e8 75 cf ff ff       	call   80104533 <myproc>
801075be:	8d 50 6c             	lea    0x6c(%eax),%edx
801075c1:	89 55 cc             	mov    %edx,-0x34(%ebp)
801075c4:	e8 6a cf ff ff       	call   80104533 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801075c9:	8b 40 10             	mov    0x10(%eax),%eax
801075cc:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801075d0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801075d3:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801075d7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801075db:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801075de:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801075e2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801075e6:	8b 55 cc             	mov    -0x34(%ebp),%edx
801075e9:	89 54 24 08          	mov    %edx,0x8(%esp)
801075ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801075f1:	c7 04 24 bc 9f 10 80 	movl   $0x80109fbc,(%esp)
801075f8:	e8 c4 8d ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801075fd:	e8 31 cf ff ff       	call   80104533 <myproc>
80107602:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107609:	eb 01                	jmp    8010760c <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010760b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010760c:	e8 22 cf ff ff       	call   80104533 <myproc>
80107611:	85 c0                	test   %eax,%eax
80107613:	74 22                	je     80107637 <trap+0x22a>
80107615:	e8 19 cf ff ff       	call   80104533 <myproc>
8010761a:	8b 40 24             	mov    0x24(%eax),%eax
8010761d:	85 c0                	test   %eax,%eax
8010761f:	74 16                	je     80107637 <trap+0x22a>
80107621:	8b 45 08             	mov    0x8(%ebp),%eax
80107624:	8b 40 3c             	mov    0x3c(%eax),%eax
80107627:	0f b7 c0             	movzwl %ax,%eax
8010762a:	83 e0 03             	and    $0x3,%eax
8010762d:	83 f8 03             	cmp    $0x3,%eax
80107630:	75 05                	jne    80107637 <trap+0x22a>
    exit();
80107632:	e8 8d d3 ff ff       	call   801049c4 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107637:	e8 f7 ce ff ff       	call   80104533 <myproc>
8010763c:	85 c0                	test   %eax,%eax
8010763e:	74 1d                	je     8010765d <trap+0x250>
80107640:	e8 ee ce ff ff       	call   80104533 <myproc>
80107645:	8b 40 0c             	mov    0xc(%eax),%eax
80107648:	83 f8 04             	cmp    $0x4,%eax
8010764b:	75 10                	jne    8010765d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010764d:	8b 45 08             	mov    0x8(%ebp),%eax
80107650:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107653:	83 f8 20             	cmp    $0x20,%eax
80107656:	75 05                	jne    8010765d <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80107658:	e8 17 d7 ff ff       	call   80104d74 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010765d:	e8 d1 ce ff ff       	call   80104533 <myproc>
80107662:	85 c0                	test   %eax,%eax
80107664:	74 22                	je     80107688 <trap+0x27b>
80107666:	e8 c8 ce ff ff       	call   80104533 <myproc>
8010766b:	8b 40 24             	mov    0x24(%eax),%eax
8010766e:	85 c0                	test   %eax,%eax
80107670:	74 16                	je     80107688 <trap+0x27b>
80107672:	8b 45 08             	mov    0x8(%ebp),%eax
80107675:	8b 40 3c             	mov    0x3c(%eax),%eax
80107678:	0f b7 c0             	movzwl %ax,%eax
8010767b:	83 e0 03             	and    $0x3,%eax
8010767e:	83 f8 03             	cmp    $0x3,%eax
80107681:	75 05                	jne    80107688 <trap+0x27b>
    exit();
80107683:	e8 3c d3 ff ff       	call   801049c4 <exit>
}
80107688:	83 c4 4c             	add    $0x4c,%esp
8010768b:	5b                   	pop    %ebx
8010768c:	5e                   	pop    %esi
8010768d:	5f                   	pop    %edi
8010768e:	5d                   	pop    %ebp
8010768f:	c3                   	ret    

80107690 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107690:	55                   	push   %ebp
80107691:	89 e5                	mov    %esp,%ebp
80107693:	83 ec 14             	sub    $0x14,%esp
80107696:	8b 45 08             	mov    0x8(%ebp),%eax
80107699:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010769d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801076a0:	89 c2                	mov    %eax,%edx
801076a2:	ec                   	in     (%dx),%al
801076a3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801076a6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801076a9:	c9                   	leave  
801076aa:	c3                   	ret    

801076ab <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801076ab:	55                   	push   %ebp
801076ac:	89 e5                	mov    %esp,%ebp
801076ae:	83 ec 08             	sub    $0x8,%esp
801076b1:	8b 45 08             	mov    0x8(%ebp),%eax
801076b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801076b7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801076bb:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801076be:	8a 45 f8             	mov    -0x8(%ebp),%al
801076c1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801076c4:	ee                   	out    %al,(%dx)
}
801076c5:	c9                   	leave  
801076c6:	c3                   	ret    

801076c7 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801076c7:	55                   	push   %ebp
801076c8:	89 e5                	mov    %esp,%ebp
801076ca:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801076cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801076d4:	00 
801076d5:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801076dc:	e8 ca ff ff ff       	call   801076ab <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801076e1:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801076e8:	00 
801076e9:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801076f0:	e8 b6 ff ff ff       	call   801076ab <outb>
  outb(COM1+0, 115200/9600);
801076f5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801076fc:	00 
801076fd:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107704:	e8 a2 ff ff ff       	call   801076ab <outb>
  outb(COM1+1, 0);
80107709:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107710:	00 
80107711:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107718:	e8 8e ff ff ff       	call   801076ab <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
8010771d:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107724:	00 
80107725:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
8010772c:	e8 7a ff ff ff       	call   801076ab <outb>
  outb(COM1+4, 0);
80107731:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107738:	00 
80107739:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107740:	e8 66 ff ff ff       	call   801076ab <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107745:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010774c:	00 
8010774d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107754:	e8 52 ff ff ff       	call   801076ab <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107759:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107760:	e8 2b ff ff ff       	call   80107690 <inb>
80107765:	3c ff                	cmp    $0xff,%al
80107767:	75 02                	jne    8010776b <uartinit+0xa4>
    return;
80107769:	eb 5b                	jmp    801077c6 <uartinit+0xff>
  uart = 1;
8010776b:	c7 05 24 d9 10 80 01 	movl   $0x1,0x8010d924
80107772:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107775:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
8010777c:	e8 0f ff ff ff       	call   80107690 <inb>
  inb(COM1+0);
80107781:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107788:	e8 03 ff ff ff       	call   80107690 <inb>
  ioapicenable(IRQ_COM1, 0);
8010778d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107794:	00 
80107795:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010779c:	e8 2e b5 ff ff       	call   80102ccf <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801077a1:	c7 45 f4 80 a0 10 80 	movl   $0x8010a080,-0xc(%ebp)
801077a8:	eb 13                	jmp    801077bd <uartinit+0xf6>
    uartputc(*p);
801077aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ad:	8a 00                	mov    (%eax),%al
801077af:	0f be c0             	movsbl %al,%eax
801077b2:	89 04 24             	mov    %eax,(%esp)
801077b5:	e8 0e 00 00 00       	call   801077c8 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801077ba:	ff 45 f4             	incl   -0xc(%ebp)
801077bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c0:	8a 00                	mov    (%eax),%al
801077c2:	84 c0                	test   %al,%al
801077c4:	75 e4                	jne    801077aa <uartinit+0xe3>
    uartputc(*p);
}
801077c6:	c9                   	leave  
801077c7:	c3                   	ret    

801077c8 <uartputc>:

void
uartputc(int c)
{
801077c8:	55                   	push   %ebp
801077c9:	89 e5                	mov    %esp,%ebp
801077cb:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801077ce:	a1 24 d9 10 80       	mov    0x8010d924,%eax
801077d3:	85 c0                	test   %eax,%eax
801077d5:	75 02                	jne    801077d9 <uartputc+0x11>
    return;
801077d7:	eb 4a                	jmp    80107823 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801077d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801077e0:	eb 0f                	jmp    801077f1 <uartputc+0x29>
    microdelay(10);
801077e2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801077e9:	e8 1a bb ff ff       	call   80103308 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801077ee:	ff 45 f4             	incl   -0xc(%ebp)
801077f1:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801077f5:	7f 16                	jg     8010780d <uartputc+0x45>
801077f7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801077fe:	e8 8d fe ff ff       	call   80107690 <inb>
80107803:	0f b6 c0             	movzbl %al,%eax
80107806:	83 e0 20             	and    $0x20,%eax
80107809:	85 c0                	test   %eax,%eax
8010780b:	74 d5                	je     801077e2 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
8010780d:	8b 45 08             	mov    0x8(%ebp),%eax
80107810:	0f b6 c0             	movzbl %al,%eax
80107813:	89 44 24 04          	mov    %eax,0x4(%esp)
80107817:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010781e:	e8 88 fe ff ff       	call   801076ab <outb>
}
80107823:	c9                   	leave  
80107824:	c3                   	ret    

80107825 <uartgetc>:

static int
uartgetc(void)
{
80107825:	55                   	push   %ebp
80107826:	89 e5                	mov    %esp,%ebp
80107828:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010782b:	a1 24 d9 10 80       	mov    0x8010d924,%eax
80107830:	85 c0                	test   %eax,%eax
80107832:	75 07                	jne    8010783b <uartgetc+0x16>
    return -1;
80107834:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107839:	eb 2c                	jmp    80107867 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010783b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107842:	e8 49 fe ff ff       	call   80107690 <inb>
80107847:	0f b6 c0             	movzbl %al,%eax
8010784a:	83 e0 01             	and    $0x1,%eax
8010784d:	85 c0                	test   %eax,%eax
8010784f:	75 07                	jne    80107858 <uartgetc+0x33>
    return -1;
80107851:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107856:	eb 0f                	jmp    80107867 <uartgetc+0x42>
  return inb(COM1+0);
80107858:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010785f:	e8 2c fe ff ff       	call   80107690 <inb>
80107864:	0f b6 c0             	movzbl %al,%eax
}
80107867:	c9                   	leave  
80107868:	c3                   	ret    

80107869 <uartintr>:

void
uartintr(void)
{
80107869:	55                   	push   %ebp
8010786a:	89 e5                	mov    %esp,%ebp
8010786c:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
8010786f:	c7 04 24 25 78 10 80 	movl   $0x80107825,(%esp)
80107876:	e8 7a 8f ff ff       	call   801007f5 <consoleintr>
}
8010787b:	c9                   	leave  
8010787c:	c3                   	ret    
8010787d:	00 00                	add    %al,(%eax)
	...

80107880 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107880:	6a 00                	push   $0x0
  pushl $0
80107882:	6a 00                	push   $0x0
  jmp alltraps
80107884:	e9 af f9 ff ff       	jmp    80107238 <alltraps>

80107889 <vector1>:
.globl vector1
vector1:
  pushl $0
80107889:	6a 00                	push   $0x0
  pushl $1
8010788b:	6a 01                	push   $0x1
  jmp alltraps
8010788d:	e9 a6 f9 ff ff       	jmp    80107238 <alltraps>

80107892 <vector2>:
.globl vector2
vector2:
  pushl $0
80107892:	6a 00                	push   $0x0
  pushl $2
80107894:	6a 02                	push   $0x2
  jmp alltraps
80107896:	e9 9d f9 ff ff       	jmp    80107238 <alltraps>

8010789b <vector3>:
.globl vector3
vector3:
  pushl $0
8010789b:	6a 00                	push   $0x0
  pushl $3
8010789d:	6a 03                	push   $0x3
  jmp alltraps
8010789f:	e9 94 f9 ff ff       	jmp    80107238 <alltraps>

801078a4 <vector4>:
.globl vector4
vector4:
  pushl $0
801078a4:	6a 00                	push   $0x0
  pushl $4
801078a6:	6a 04                	push   $0x4
  jmp alltraps
801078a8:	e9 8b f9 ff ff       	jmp    80107238 <alltraps>

801078ad <vector5>:
.globl vector5
vector5:
  pushl $0
801078ad:	6a 00                	push   $0x0
  pushl $5
801078af:	6a 05                	push   $0x5
  jmp alltraps
801078b1:	e9 82 f9 ff ff       	jmp    80107238 <alltraps>

801078b6 <vector6>:
.globl vector6
vector6:
  pushl $0
801078b6:	6a 00                	push   $0x0
  pushl $6
801078b8:	6a 06                	push   $0x6
  jmp alltraps
801078ba:	e9 79 f9 ff ff       	jmp    80107238 <alltraps>

801078bf <vector7>:
.globl vector7
vector7:
  pushl $0
801078bf:	6a 00                	push   $0x0
  pushl $7
801078c1:	6a 07                	push   $0x7
  jmp alltraps
801078c3:	e9 70 f9 ff ff       	jmp    80107238 <alltraps>

801078c8 <vector8>:
.globl vector8
vector8:
  pushl $8
801078c8:	6a 08                	push   $0x8
  jmp alltraps
801078ca:	e9 69 f9 ff ff       	jmp    80107238 <alltraps>

801078cf <vector9>:
.globl vector9
vector9:
  pushl $0
801078cf:	6a 00                	push   $0x0
  pushl $9
801078d1:	6a 09                	push   $0x9
  jmp alltraps
801078d3:	e9 60 f9 ff ff       	jmp    80107238 <alltraps>

801078d8 <vector10>:
.globl vector10
vector10:
  pushl $10
801078d8:	6a 0a                	push   $0xa
  jmp alltraps
801078da:	e9 59 f9 ff ff       	jmp    80107238 <alltraps>

801078df <vector11>:
.globl vector11
vector11:
  pushl $11
801078df:	6a 0b                	push   $0xb
  jmp alltraps
801078e1:	e9 52 f9 ff ff       	jmp    80107238 <alltraps>

801078e6 <vector12>:
.globl vector12
vector12:
  pushl $12
801078e6:	6a 0c                	push   $0xc
  jmp alltraps
801078e8:	e9 4b f9 ff ff       	jmp    80107238 <alltraps>

801078ed <vector13>:
.globl vector13
vector13:
  pushl $13
801078ed:	6a 0d                	push   $0xd
  jmp alltraps
801078ef:	e9 44 f9 ff ff       	jmp    80107238 <alltraps>

801078f4 <vector14>:
.globl vector14
vector14:
  pushl $14
801078f4:	6a 0e                	push   $0xe
  jmp alltraps
801078f6:	e9 3d f9 ff ff       	jmp    80107238 <alltraps>

801078fb <vector15>:
.globl vector15
vector15:
  pushl $0
801078fb:	6a 00                	push   $0x0
  pushl $15
801078fd:	6a 0f                	push   $0xf
  jmp alltraps
801078ff:	e9 34 f9 ff ff       	jmp    80107238 <alltraps>

80107904 <vector16>:
.globl vector16
vector16:
  pushl $0
80107904:	6a 00                	push   $0x0
  pushl $16
80107906:	6a 10                	push   $0x10
  jmp alltraps
80107908:	e9 2b f9 ff ff       	jmp    80107238 <alltraps>

8010790d <vector17>:
.globl vector17
vector17:
  pushl $17
8010790d:	6a 11                	push   $0x11
  jmp alltraps
8010790f:	e9 24 f9 ff ff       	jmp    80107238 <alltraps>

80107914 <vector18>:
.globl vector18
vector18:
  pushl $0
80107914:	6a 00                	push   $0x0
  pushl $18
80107916:	6a 12                	push   $0x12
  jmp alltraps
80107918:	e9 1b f9 ff ff       	jmp    80107238 <alltraps>

8010791d <vector19>:
.globl vector19
vector19:
  pushl $0
8010791d:	6a 00                	push   $0x0
  pushl $19
8010791f:	6a 13                	push   $0x13
  jmp alltraps
80107921:	e9 12 f9 ff ff       	jmp    80107238 <alltraps>

80107926 <vector20>:
.globl vector20
vector20:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $20
80107928:	6a 14                	push   $0x14
  jmp alltraps
8010792a:	e9 09 f9 ff ff       	jmp    80107238 <alltraps>

8010792f <vector21>:
.globl vector21
vector21:
  pushl $0
8010792f:	6a 00                	push   $0x0
  pushl $21
80107931:	6a 15                	push   $0x15
  jmp alltraps
80107933:	e9 00 f9 ff ff       	jmp    80107238 <alltraps>

80107938 <vector22>:
.globl vector22
vector22:
  pushl $0
80107938:	6a 00                	push   $0x0
  pushl $22
8010793a:	6a 16                	push   $0x16
  jmp alltraps
8010793c:	e9 f7 f8 ff ff       	jmp    80107238 <alltraps>

80107941 <vector23>:
.globl vector23
vector23:
  pushl $0
80107941:	6a 00                	push   $0x0
  pushl $23
80107943:	6a 17                	push   $0x17
  jmp alltraps
80107945:	e9 ee f8 ff ff       	jmp    80107238 <alltraps>

8010794a <vector24>:
.globl vector24
vector24:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $24
8010794c:	6a 18                	push   $0x18
  jmp alltraps
8010794e:	e9 e5 f8 ff ff       	jmp    80107238 <alltraps>

80107953 <vector25>:
.globl vector25
vector25:
  pushl $0
80107953:	6a 00                	push   $0x0
  pushl $25
80107955:	6a 19                	push   $0x19
  jmp alltraps
80107957:	e9 dc f8 ff ff       	jmp    80107238 <alltraps>

8010795c <vector26>:
.globl vector26
vector26:
  pushl $0
8010795c:	6a 00                	push   $0x0
  pushl $26
8010795e:	6a 1a                	push   $0x1a
  jmp alltraps
80107960:	e9 d3 f8 ff ff       	jmp    80107238 <alltraps>

80107965 <vector27>:
.globl vector27
vector27:
  pushl $0
80107965:	6a 00                	push   $0x0
  pushl $27
80107967:	6a 1b                	push   $0x1b
  jmp alltraps
80107969:	e9 ca f8 ff ff       	jmp    80107238 <alltraps>

8010796e <vector28>:
.globl vector28
vector28:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $28
80107970:	6a 1c                	push   $0x1c
  jmp alltraps
80107972:	e9 c1 f8 ff ff       	jmp    80107238 <alltraps>

80107977 <vector29>:
.globl vector29
vector29:
  pushl $0
80107977:	6a 00                	push   $0x0
  pushl $29
80107979:	6a 1d                	push   $0x1d
  jmp alltraps
8010797b:	e9 b8 f8 ff ff       	jmp    80107238 <alltraps>

80107980 <vector30>:
.globl vector30
vector30:
  pushl $0
80107980:	6a 00                	push   $0x0
  pushl $30
80107982:	6a 1e                	push   $0x1e
  jmp alltraps
80107984:	e9 af f8 ff ff       	jmp    80107238 <alltraps>

80107989 <vector31>:
.globl vector31
vector31:
  pushl $0
80107989:	6a 00                	push   $0x0
  pushl $31
8010798b:	6a 1f                	push   $0x1f
  jmp alltraps
8010798d:	e9 a6 f8 ff ff       	jmp    80107238 <alltraps>

80107992 <vector32>:
.globl vector32
vector32:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $32
80107994:	6a 20                	push   $0x20
  jmp alltraps
80107996:	e9 9d f8 ff ff       	jmp    80107238 <alltraps>

8010799b <vector33>:
.globl vector33
vector33:
  pushl $0
8010799b:	6a 00                	push   $0x0
  pushl $33
8010799d:	6a 21                	push   $0x21
  jmp alltraps
8010799f:	e9 94 f8 ff ff       	jmp    80107238 <alltraps>

801079a4 <vector34>:
.globl vector34
vector34:
  pushl $0
801079a4:	6a 00                	push   $0x0
  pushl $34
801079a6:	6a 22                	push   $0x22
  jmp alltraps
801079a8:	e9 8b f8 ff ff       	jmp    80107238 <alltraps>

801079ad <vector35>:
.globl vector35
vector35:
  pushl $0
801079ad:	6a 00                	push   $0x0
  pushl $35
801079af:	6a 23                	push   $0x23
  jmp alltraps
801079b1:	e9 82 f8 ff ff       	jmp    80107238 <alltraps>

801079b6 <vector36>:
.globl vector36
vector36:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $36
801079b8:	6a 24                	push   $0x24
  jmp alltraps
801079ba:	e9 79 f8 ff ff       	jmp    80107238 <alltraps>

801079bf <vector37>:
.globl vector37
vector37:
  pushl $0
801079bf:	6a 00                	push   $0x0
  pushl $37
801079c1:	6a 25                	push   $0x25
  jmp alltraps
801079c3:	e9 70 f8 ff ff       	jmp    80107238 <alltraps>

801079c8 <vector38>:
.globl vector38
vector38:
  pushl $0
801079c8:	6a 00                	push   $0x0
  pushl $38
801079ca:	6a 26                	push   $0x26
  jmp alltraps
801079cc:	e9 67 f8 ff ff       	jmp    80107238 <alltraps>

801079d1 <vector39>:
.globl vector39
vector39:
  pushl $0
801079d1:	6a 00                	push   $0x0
  pushl $39
801079d3:	6a 27                	push   $0x27
  jmp alltraps
801079d5:	e9 5e f8 ff ff       	jmp    80107238 <alltraps>

801079da <vector40>:
.globl vector40
vector40:
  pushl $0
801079da:	6a 00                	push   $0x0
  pushl $40
801079dc:	6a 28                	push   $0x28
  jmp alltraps
801079de:	e9 55 f8 ff ff       	jmp    80107238 <alltraps>

801079e3 <vector41>:
.globl vector41
vector41:
  pushl $0
801079e3:	6a 00                	push   $0x0
  pushl $41
801079e5:	6a 29                	push   $0x29
  jmp alltraps
801079e7:	e9 4c f8 ff ff       	jmp    80107238 <alltraps>

801079ec <vector42>:
.globl vector42
vector42:
  pushl $0
801079ec:	6a 00                	push   $0x0
  pushl $42
801079ee:	6a 2a                	push   $0x2a
  jmp alltraps
801079f0:	e9 43 f8 ff ff       	jmp    80107238 <alltraps>

801079f5 <vector43>:
.globl vector43
vector43:
  pushl $0
801079f5:	6a 00                	push   $0x0
  pushl $43
801079f7:	6a 2b                	push   $0x2b
  jmp alltraps
801079f9:	e9 3a f8 ff ff       	jmp    80107238 <alltraps>

801079fe <vector44>:
.globl vector44
vector44:
  pushl $0
801079fe:	6a 00                	push   $0x0
  pushl $44
80107a00:	6a 2c                	push   $0x2c
  jmp alltraps
80107a02:	e9 31 f8 ff ff       	jmp    80107238 <alltraps>

80107a07 <vector45>:
.globl vector45
vector45:
  pushl $0
80107a07:	6a 00                	push   $0x0
  pushl $45
80107a09:	6a 2d                	push   $0x2d
  jmp alltraps
80107a0b:	e9 28 f8 ff ff       	jmp    80107238 <alltraps>

80107a10 <vector46>:
.globl vector46
vector46:
  pushl $0
80107a10:	6a 00                	push   $0x0
  pushl $46
80107a12:	6a 2e                	push   $0x2e
  jmp alltraps
80107a14:	e9 1f f8 ff ff       	jmp    80107238 <alltraps>

80107a19 <vector47>:
.globl vector47
vector47:
  pushl $0
80107a19:	6a 00                	push   $0x0
  pushl $47
80107a1b:	6a 2f                	push   $0x2f
  jmp alltraps
80107a1d:	e9 16 f8 ff ff       	jmp    80107238 <alltraps>

80107a22 <vector48>:
.globl vector48
vector48:
  pushl $0
80107a22:	6a 00                	push   $0x0
  pushl $48
80107a24:	6a 30                	push   $0x30
  jmp alltraps
80107a26:	e9 0d f8 ff ff       	jmp    80107238 <alltraps>

80107a2b <vector49>:
.globl vector49
vector49:
  pushl $0
80107a2b:	6a 00                	push   $0x0
  pushl $49
80107a2d:	6a 31                	push   $0x31
  jmp alltraps
80107a2f:	e9 04 f8 ff ff       	jmp    80107238 <alltraps>

80107a34 <vector50>:
.globl vector50
vector50:
  pushl $0
80107a34:	6a 00                	push   $0x0
  pushl $50
80107a36:	6a 32                	push   $0x32
  jmp alltraps
80107a38:	e9 fb f7 ff ff       	jmp    80107238 <alltraps>

80107a3d <vector51>:
.globl vector51
vector51:
  pushl $0
80107a3d:	6a 00                	push   $0x0
  pushl $51
80107a3f:	6a 33                	push   $0x33
  jmp alltraps
80107a41:	e9 f2 f7 ff ff       	jmp    80107238 <alltraps>

80107a46 <vector52>:
.globl vector52
vector52:
  pushl $0
80107a46:	6a 00                	push   $0x0
  pushl $52
80107a48:	6a 34                	push   $0x34
  jmp alltraps
80107a4a:	e9 e9 f7 ff ff       	jmp    80107238 <alltraps>

80107a4f <vector53>:
.globl vector53
vector53:
  pushl $0
80107a4f:	6a 00                	push   $0x0
  pushl $53
80107a51:	6a 35                	push   $0x35
  jmp alltraps
80107a53:	e9 e0 f7 ff ff       	jmp    80107238 <alltraps>

80107a58 <vector54>:
.globl vector54
vector54:
  pushl $0
80107a58:	6a 00                	push   $0x0
  pushl $54
80107a5a:	6a 36                	push   $0x36
  jmp alltraps
80107a5c:	e9 d7 f7 ff ff       	jmp    80107238 <alltraps>

80107a61 <vector55>:
.globl vector55
vector55:
  pushl $0
80107a61:	6a 00                	push   $0x0
  pushl $55
80107a63:	6a 37                	push   $0x37
  jmp alltraps
80107a65:	e9 ce f7 ff ff       	jmp    80107238 <alltraps>

80107a6a <vector56>:
.globl vector56
vector56:
  pushl $0
80107a6a:	6a 00                	push   $0x0
  pushl $56
80107a6c:	6a 38                	push   $0x38
  jmp alltraps
80107a6e:	e9 c5 f7 ff ff       	jmp    80107238 <alltraps>

80107a73 <vector57>:
.globl vector57
vector57:
  pushl $0
80107a73:	6a 00                	push   $0x0
  pushl $57
80107a75:	6a 39                	push   $0x39
  jmp alltraps
80107a77:	e9 bc f7 ff ff       	jmp    80107238 <alltraps>

80107a7c <vector58>:
.globl vector58
vector58:
  pushl $0
80107a7c:	6a 00                	push   $0x0
  pushl $58
80107a7e:	6a 3a                	push   $0x3a
  jmp alltraps
80107a80:	e9 b3 f7 ff ff       	jmp    80107238 <alltraps>

80107a85 <vector59>:
.globl vector59
vector59:
  pushl $0
80107a85:	6a 00                	push   $0x0
  pushl $59
80107a87:	6a 3b                	push   $0x3b
  jmp alltraps
80107a89:	e9 aa f7 ff ff       	jmp    80107238 <alltraps>

80107a8e <vector60>:
.globl vector60
vector60:
  pushl $0
80107a8e:	6a 00                	push   $0x0
  pushl $60
80107a90:	6a 3c                	push   $0x3c
  jmp alltraps
80107a92:	e9 a1 f7 ff ff       	jmp    80107238 <alltraps>

80107a97 <vector61>:
.globl vector61
vector61:
  pushl $0
80107a97:	6a 00                	push   $0x0
  pushl $61
80107a99:	6a 3d                	push   $0x3d
  jmp alltraps
80107a9b:	e9 98 f7 ff ff       	jmp    80107238 <alltraps>

80107aa0 <vector62>:
.globl vector62
vector62:
  pushl $0
80107aa0:	6a 00                	push   $0x0
  pushl $62
80107aa2:	6a 3e                	push   $0x3e
  jmp alltraps
80107aa4:	e9 8f f7 ff ff       	jmp    80107238 <alltraps>

80107aa9 <vector63>:
.globl vector63
vector63:
  pushl $0
80107aa9:	6a 00                	push   $0x0
  pushl $63
80107aab:	6a 3f                	push   $0x3f
  jmp alltraps
80107aad:	e9 86 f7 ff ff       	jmp    80107238 <alltraps>

80107ab2 <vector64>:
.globl vector64
vector64:
  pushl $0
80107ab2:	6a 00                	push   $0x0
  pushl $64
80107ab4:	6a 40                	push   $0x40
  jmp alltraps
80107ab6:	e9 7d f7 ff ff       	jmp    80107238 <alltraps>

80107abb <vector65>:
.globl vector65
vector65:
  pushl $0
80107abb:	6a 00                	push   $0x0
  pushl $65
80107abd:	6a 41                	push   $0x41
  jmp alltraps
80107abf:	e9 74 f7 ff ff       	jmp    80107238 <alltraps>

80107ac4 <vector66>:
.globl vector66
vector66:
  pushl $0
80107ac4:	6a 00                	push   $0x0
  pushl $66
80107ac6:	6a 42                	push   $0x42
  jmp alltraps
80107ac8:	e9 6b f7 ff ff       	jmp    80107238 <alltraps>

80107acd <vector67>:
.globl vector67
vector67:
  pushl $0
80107acd:	6a 00                	push   $0x0
  pushl $67
80107acf:	6a 43                	push   $0x43
  jmp alltraps
80107ad1:	e9 62 f7 ff ff       	jmp    80107238 <alltraps>

80107ad6 <vector68>:
.globl vector68
vector68:
  pushl $0
80107ad6:	6a 00                	push   $0x0
  pushl $68
80107ad8:	6a 44                	push   $0x44
  jmp alltraps
80107ada:	e9 59 f7 ff ff       	jmp    80107238 <alltraps>

80107adf <vector69>:
.globl vector69
vector69:
  pushl $0
80107adf:	6a 00                	push   $0x0
  pushl $69
80107ae1:	6a 45                	push   $0x45
  jmp alltraps
80107ae3:	e9 50 f7 ff ff       	jmp    80107238 <alltraps>

80107ae8 <vector70>:
.globl vector70
vector70:
  pushl $0
80107ae8:	6a 00                	push   $0x0
  pushl $70
80107aea:	6a 46                	push   $0x46
  jmp alltraps
80107aec:	e9 47 f7 ff ff       	jmp    80107238 <alltraps>

80107af1 <vector71>:
.globl vector71
vector71:
  pushl $0
80107af1:	6a 00                	push   $0x0
  pushl $71
80107af3:	6a 47                	push   $0x47
  jmp alltraps
80107af5:	e9 3e f7 ff ff       	jmp    80107238 <alltraps>

80107afa <vector72>:
.globl vector72
vector72:
  pushl $0
80107afa:	6a 00                	push   $0x0
  pushl $72
80107afc:	6a 48                	push   $0x48
  jmp alltraps
80107afe:	e9 35 f7 ff ff       	jmp    80107238 <alltraps>

80107b03 <vector73>:
.globl vector73
vector73:
  pushl $0
80107b03:	6a 00                	push   $0x0
  pushl $73
80107b05:	6a 49                	push   $0x49
  jmp alltraps
80107b07:	e9 2c f7 ff ff       	jmp    80107238 <alltraps>

80107b0c <vector74>:
.globl vector74
vector74:
  pushl $0
80107b0c:	6a 00                	push   $0x0
  pushl $74
80107b0e:	6a 4a                	push   $0x4a
  jmp alltraps
80107b10:	e9 23 f7 ff ff       	jmp    80107238 <alltraps>

80107b15 <vector75>:
.globl vector75
vector75:
  pushl $0
80107b15:	6a 00                	push   $0x0
  pushl $75
80107b17:	6a 4b                	push   $0x4b
  jmp alltraps
80107b19:	e9 1a f7 ff ff       	jmp    80107238 <alltraps>

80107b1e <vector76>:
.globl vector76
vector76:
  pushl $0
80107b1e:	6a 00                	push   $0x0
  pushl $76
80107b20:	6a 4c                	push   $0x4c
  jmp alltraps
80107b22:	e9 11 f7 ff ff       	jmp    80107238 <alltraps>

80107b27 <vector77>:
.globl vector77
vector77:
  pushl $0
80107b27:	6a 00                	push   $0x0
  pushl $77
80107b29:	6a 4d                	push   $0x4d
  jmp alltraps
80107b2b:	e9 08 f7 ff ff       	jmp    80107238 <alltraps>

80107b30 <vector78>:
.globl vector78
vector78:
  pushl $0
80107b30:	6a 00                	push   $0x0
  pushl $78
80107b32:	6a 4e                	push   $0x4e
  jmp alltraps
80107b34:	e9 ff f6 ff ff       	jmp    80107238 <alltraps>

80107b39 <vector79>:
.globl vector79
vector79:
  pushl $0
80107b39:	6a 00                	push   $0x0
  pushl $79
80107b3b:	6a 4f                	push   $0x4f
  jmp alltraps
80107b3d:	e9 f6 f6 ff ff       	jmp    80107238 <alltraps>

80107b42 <vector80>:
.globl vector80
vector80:
  pushl $0
80107b42:	6a 00                	push   $0x0
  pushl $80
80107b44:	6a 50                	push   $0x50
  jmp alltraps
80107b46:	e9 ed f6 ff ff       	jmp    80107238 <alltraps>

80107b4b <vector81>:
.globl vector81
vector81:
  pushl $0
80107b4b:	6a 00                	push   $0x0
  pushl $81
80107b4d:	6a 51                	push   $0x51
  jmp alltraps
80107b4f:	e9 e4 f6 ff ff       	jmp    80107238 <alltraps>

80107b54 <vector82>:
.globl vector82
vector82:
  pushl $0
80107b54:	6a 00                	push   $0x0
  pushl $82
80107b56:	6a 52                	push   $0x52
  jmp alltraps
80107b58:	e9 db f6 ff ff       	jmp    80107238 <alltraps>

80107b5d <vector83>:
.globl vector83
vector83:
  pushl $0
80107b5d:	6a 00                	push   $0x0
  pushl $83
80107b5f:	6a 53                	push   $0x53
  jmp alltraps
80107b61:	e9 d2 f6 ff ff       	jmp    80107238 <alltraps>

80107b66 <vector84>:
.globl vector84
vector84:
  pushl $0
80107b66:	6a 00                	push   $0x0
  pushl $84
80107b68:	6a 54                	push   $0x54
  jmp alltraps
80107b6a:	e9 c9 f6 ff ff       	jmp    80107238 <alltraps>

80107b6f <vector85>:
.globl vector85
vector85:
  pushl $0
80107b6f:	6a 00                	push   $0x0
  pushl $85
80107b71:	6a 55                	push   $0x55
  jmp alltraps
80107b73:	e9 c0 f6 ff ff       	jmp    80107238 <alltraps>

80107b78 <vector86>:
.globl vector86
vector86:
  pushl $0
80107b78:	6a 00                	push   $0x0
  pushl $86
80107b7a:	6a 56                	push   $0x56
  jmp alltraps
80107b7c:	e9 b7 f6 ff ff       	jmp    80107238 <alltraps>

80107b81 <vector87>:
.globl vector87
vector87:
  pushl $0
80107b81:	6a 00                	push   $0x0
  pushl $87
80107b83:	6a 57                	push   $0x57
  jmp alltraps
80107b85:	e9 ae f6 ff ff       	jmp    80107238 <alltraps>

80107b8a <vector88>:
.globl vector88
vector88:
  pushl $0
80107b8a:	6a 00                	push   $0x0
  pushl $88
80107b8c:	6a 58                	push   $0x58
  jmp alltraps
80107b8e:	e9 a5 f6 ff ff       	jmp    80107238 <alltraps>

80107b93 <vector89>:
.globl vector89
vector89:
  pushl $0
80107b93:	6a 00                	push   $0x0
  pushl $89
80107b95:	6a 59                	push   $0x59
  jmp alltraps
80107b97:	e9 9c f6 ff ff       	jmp    80107238 <alltraps>

80107b9c <vector90>:
.globl vector90
vector90:
  pushl $0
80107b9c:	6a 00                	push   $0x0
  pushl $90
80107b9e:	6a 5a                	push   $0x5a
  jmp alltraps
80107ba0:	e9 93 f6 ff ff       	jmp    80107238 <alltraps>

80107ba5 <vector91>:
.globl vector91
vector91:
  pushl $0
80107ba5:	6a 00                	push   $0x0
  pushl $91
80107ba7:	6a 5b                	push   $0x5b
  jmp alltraps
80107ba9:	e9 8a f6 ff ff       	jmp    80107238 <alltraps>

80107bae <vector92>:
.globl vector92
vector92:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $92
80107bb0:	6a 5c                	push   $0x5c
  jmp alltraps
80107bb2:	e9 81 f6 ff ff       	jmp    80107238 <alltraps>

80107bb7 <vector93>:
.globl vector93
vector93:
  pushl $0
80107bb7:	6a 00                	push   $0x0
  pushl $93
80107bb9:	6a 5d                	push   $0x5d
  jmp alltraps
80107bbb:	e9 78 f6 ff ff       	jmp    80107238 <alltraps>

80107bc0 <vector94>:
.globl vector94
vector94:
  pushl $0
80107bc0:	6a 00                	push   $0x0
  pushl $94
80107bc2:	6a 5e                	push   $0x5e
  jmp alltraps
80107bc4:	e9 6f f6 ff ff       	jmp    80107238 <alltraps>

80107bc9 <vector95>:
.globl vector95
vector95:
  pushl $0
80107bc9:	6a 00                	push   $0x0
  pushl $95
80107bcb:	6a 5f                	push   $0x5f
  jmp alltraps
80107bcd:	e9 66 f6 ff ff       	jmp    80107238 <alltraps>

80107bd2 <vector96>:
.globl vector96
vector96:
  pushl $0
80107bd2:	6a 00                	push   $0x0
  pushl $96
80107bd4:	6a 60                	push   $0x60
  jmp alltraps
80107bd6:	e9 5d f6 ff ff       	jmp    80107238 <alltraps>

80107bdb <vector97>:
.globl vector97
vector97:
  pushl $0
80107bdb:	6a 00                	push   $0x0
  pushl $97
80107bdd:	6a 61                	push   $0x61
  jmp alltraps
80107bdf:	e9 54 f6 ff ff       	jmp    80107238 <alltraps>

80107be4 <vector98>:
.globl vector98
vector98:
  pushl $0
80107be4:	6a 00                	push   $0x0
  pushl $98
80107be6:	6a 62                	push   $0x62
  jmp alltraps
80107be8:	e9 4b f6 ff ff       	jmp    80107238 <alltraps>

80107bed <vector99>:
.globl vector99
vector99:
  pushl $0
80107bed:	6a 00                	push   $0x0
  pushl $99
80107bef:	6a 63                	push   $0x63
  jmp alltraps
80107bf1:	e9 42 f6 ff ff       	jmp    80107238 <alltraps>

80107bf6 <vector100>:
.globl vector100
vector100:
  pushl $0
80107bf6:	6a 00                	push   $0x0
  pushl $100
80107bf8:	6a 64                	push   $0x64
  jmp alltraps
80107bfa:	e9 39 f6 ff ff       	jmp    80107238 <alltraps>

80107bff <vector101>:
.globl vector101
vector101:
  pushl $0
80107bff:	6a 00                	push   $0x0
  pushl $101
80107c01:	6a 65                	push   $0x65
  jmp alltraps
80107c03:	e9 30 f6 ff ff       	jmp    80107238 <alltraps>

80107c08 <vector102>:
.globl vector102
vector102:
  pushl $0
80107c08:	6a 00                	push   $0x0
  pushl $102
80107c0a:	6a 66                	push   $0x66
  jmp alltraps
80107c0c:	e9 27 f6 ff ff       	jmp    80107238 <alltraps>

80107c11 <vector103>:
.globl vector103
vector103:
  pushl $0
80107c11:	6a 00                	push   $0x0
  pushl $103
80107c13:	6a 67                	push   $0x67
  jmp alltraps
80107c15:	e9 1e f6 ff ff       	jmp    80107238 <alltraps>

80107c1a <vector104>:
.globl vector104
vector104:
  pushl $0
80107c1a:	6a 00                	push   $0x0
  pushl $104
80107c1c:	6a 68                	push   $0x68
  jmp alltraps
80107c1e:	e9 15 f6 ff ff       	jmp    80107238 <alltraps>

80107c23 <vector105>:
.globl vector105
vector105:
  pushl $0
80107c23:	6a 00                	push   $0x0
  pushl $105
80107c25:	6a 69                	push   $0x69
  jmp alltraps
80107c27:	e9 0c f6 ff ff       	jmp    80107238 <alltraps>

80107c2c <vector106>:
.globl vector106
vector106:
  pushl $0
80107c2c:	6a 00                	push   $0x0
  pushl $106
80107c2e:	6a 6a                	push   $0x6a
  jmp alltraps
80107c30:	e9 03 f6 ff ff       	jmp    80107238 <alltraps>

80107c35 <vector107>:
.globl vector107
vector107:
  pushl $0
80107c35:	6a 00                	push   $0x0
  pushl $107
80107c37:	6a 6b                	push   $0x6b
  jmp alltraps
80107c39:	e9 fa f5 ff ff       	jmp    80107238 <alltraps>

80107c3e <vector108>:
.globl vector108
vector108:
  pushl $0
80107c3e:	6a 00                	push   $0x0
  pushl $108
80107c40:	6a 6c                	push   $0x6c
  jmp alltraps
80107c42:	e9 f1 f5 ff ff       	jmp    80107238 <alltraps>

80107c47 <vector109>:
.globl vector109
vector109:
  pushl $0
80107c47:	6a 00                	push   $0x0
  pushl $109
80107c49:	6a 6d                	push   $0x6d
  jmp alltraps
80107c4b:	e9 e8 f5 ff ff       	jmp    80107238 <alltraps>

80107c50 <vector110>:
.globl vector110
vector110:
  pushl $0
80107c50:	6a 00                	push   $0x0
  pushl $110
80107c52:	6a 6e                	push   $0x6e
  jmp alltraps
80107c54:	e9 df f5 ff ff       	jmp    80107238 <alltraps>

80107c59 <vector111>:
.globl vector111
vector111:
  pushl $0
80107c59:	6a 00                	push   $0x0
  pushl $111
80107c5b:	6a 6f                	push   $0x6f
  jmp alltraps
80107c5d:	e9 d6 f5 ff ff       	jmp    80107238 <alltraps>

80107c62 <vector112>:
.globl vector112
vector112:
  pushl $0
80107c62:	6a 00                	push   $0x0
  pushl $112
80107c64:	6a 70                	push   $0x70
  jmp alltraps
80107c66:	e9 cd f5 ff ff       	jmp    80107238 <alltraps>

80107c6b <vector113>:
.globl vector113
vector113:
  pushl $0
80107c6b:	6a 00                	push   $0x0
  pushl $113
80107c6d:	6a 71                	push   $0x71
  jmp alltraps
80107c6f:	e9 c4 f5 ff ff       	jmp    80107238 <alltraps>

80107c74 <vector114>:
.globl vector114
vector114:
  pushl $0
80107c74:	6a 00                	push   $0x0
  pushl $114
80107c76:	6a 72                	push   $0x72
  jmp alltraps
80107c78:	e9 bb f5 ff ff       	jmp    80107238 <alltraps>

80107c7d <vector115>:
.globl vector115
vector115:
  pushl $0
80107c7d:	6a 00                	push   $0x0
  pushl $115
80107c7f:	6a 73                	push   $0x73
  jmp alltraps
80107c81:	e9 b2 f5 ff ff       	jmp    80107238 <alltraps>

80107c86 <vector116>:
.globl vector116
vector116:
  pushl $0
80107c86:	6a 00                	push   $0x0
  pushl $116
80107c88:	6a 74                	push   $0x74
  jmp alltraps
80107c8a:	e9 a9 f5 ff ff       	jmp    80107238 <alltraps>

80107c8f <vector117>:
.globl vector117
vector117:
  pushl $0
80107c8f:	6a 00                	push   $0x0
  pushl $117
80107c91:	6a 75                	push   $0x75
  jmp alltraps
80107c93:	e9 a0 f5 ff ff       	jmp    80107238 <alltraps>

80107c98 <vector118>:
.globl vector118
vector118:
  pushl $0
80107c98:	6a 00                	push   $0x0
  pushl $118
80107c9a:	6a 76                	push   $0x76
  jmp alltraps
80107c9c:	e9 97 f5 ff ff       	jmp    80107238 <alltraps>

80107ca1 <vector119>:
.globl vector119
vector119:
  pushl $0
80107ca1:	6a 00                	push   $0x0
  pushl $119
80107ca3:	6a 77                	push   $0x77
  jmp alltraps
80107ca5:	e9 8e f5 ff ff       	jmp    80107238 <alltraps>

80107caa <vector120>:
.globl vector120
vector120:
  pushl $0
80107caa:	6a 00                	push   $0x0
  pushl $120
80107cac:	6a 78                	push   $0x78
  jmp alltraps
80107cae:	e9 85 f5 ff ff       	jmp    80107238 <alltraps>

80107cb3 <vector121>:
.globl vector121
vector121:
  pushl $0
80107cb3:	6a 00                	push   $0x0
  pushl $121
80107cb5:	6a 79                	push   $0x79
  jmp alltraps
80107cb7:	e9 7c f5 ff ff       	jmp    80107238 <alltraps>

80107cbc <vector122>:
.globl vector122
vector122:
  pushl $0
80107cbc:	6a 00                	push   $0x0
  pushl $122
80107cbe:	6a 7a                	push   $0x7a
  jmp alltraps
80107cc0:	e9 73 f5 ff ff       	jmp    80107238 <alltraps>

80107cc5 <vector123>:
.globl vector123
vector123:
  pushl $0
80107cc5:	6a 00                	push   $0x0
  pushl $123
80107cc7:	6a 7b                	push   $0x7b
  jmp alltraps
80107cc9:	e9 6a f5 ff ff       	jmp    80107238 <alltraps>

80107cce <vector124>:
.globl vector124
vector124:
  pushl $0
80107cce:	6a 00                	push   $0x0
  pushl $124
80107cd0:	6a 7c                	push   $0x7c
  jmp alltraps
80107cd2:	e9 61 f5 ff ff       	jmp    80107238 <alltraps>

80107cd7 <vector125>:
.globl vector125
vector125:
  pushl $0
80107cd7:	6a 00                	push   $0x0
  pushl $125
80107cd9:	6a 7d                	push   $0x7d
  jmp alltraps
80107cdb:	e9 58 f5 ff ff       	jmp    80107238 <alltraps>

80107ce0 <vector126>:
.globl vector126
vector126:
  pushl $0
80107ce0:	6a 00                	push   $0x0
  pushl $126
80107ce2:	6a 7e                	push   $0x7e
  jmp alltraps
80107ce4:	e9 4f f5 ff ff       	jmp    80107238 <alltraps>

80107ce9 <vector127>:
.globl vector127
vector127:
  pushl $0
80107ce9:	6a 00                	push   $0x0
  pushl $127
80107ceb:	6a 7f                	push   $0x7f
  jmp alltraps
80107ced:	e9 46 f5 ff ff       	jmp    80107238 <alltraps>

80107cf2 <vector128>:
.globl vector128
vector128:
  pushl $0
80107cf2:	6a 00                	push   $0x0
  pushl $128
80107cf4:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107cf9:	e9 3a f5 ff ff       	jmp    80107238 <alltraps>

80107cfe <vector129>:
.globl vector129
vector129:
  pushl $0
80107cfe:	6a 00                	push   $0x0
  pushl $129
80107d00:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107d05:	e9 2e f5 ff ff       	jmp    80107238 <alltraps>

80107d0a <vector130>:
.globl vector130
vector130:
  pushl $0
80107d0a:	6a 00                	push   $0x0
  pushl $130
80107d0c:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107d11:	e9 22 f5 ff ff       	jmp    80107238 <alltraps>

80107d16 <vector131>:
.globl vector131
vector131:
  pushl $0
80107d16:	6a 00                	push   $0x0
  pushl $131
80107d18:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107d1d:	e9 16 f5 ff ff       	jmp    80107238 <alltraps>

80107d22 <vector132>:
.globl vector132
vector132:
  pushl $0
80107d22:	6a 00                	push   $0x0
  pushl $132
80107d24:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107d29:	e9 0a f5 ff ff       	jmp    80107238 <alltraps>

80107d2e <vector133>:
.globl vector133
vector133:
  pushl $0
80107d2e:	6a 00                	push   $0x0
  pushl $133
80107d30:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107d35:	e9 fe f4 ff ff       	jmp    80107238 <alltraps>

80107d3a <vector134>:
.globl vector134
vector134:
  pushl $0
80107d3a:	6a 00                	push   $0x0
  pushl $134
80107d3c:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107d41:	e9 f2 f4 ff ff       	jmp    80107238 <alltraps>

80107d46 <vector135>:
.globl vector135
vector135:
  pushl $0
80107d46:	6a 00                	push   $0x0
  pushl $135
80107d48:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107d4d:	e9 e6 f4 ff ff       	jmp    80107238 <alltraps>

80107d52 <vector136>:
.globl vector136
vector136:
  pushl $0
80107d52:	6a 00                	push   $0x0
  pushl $136
80107d54:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107d59:	e9 da f4 ff ff       	jmp    80107238 <alltraps>

80107d5e <vector137>:
.globl vector137
vector137:
  pushl $0
80107d5e:	6a 00                	push   $0x0
  pushl $137
80107d60:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107d65:	e9 ce f4 ff ff       	jmp    80107238 <alltraps>

80107d6a <vector138>:
.globl vector138
vector138:
  pushl $0
80107d6a:	6a 00                	push   $0x0
  pushl $138
80107d6c:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107d71:	e9 c2 f4 ff ff       	jmp    80107238 <alltraps>

80107d76 <vector139>:
.globl vector139
vector139:
  pushl $0
80107d76:	6a 00                	push   $0x0
  pushl $139
80107d78:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107d7d:	e9 b6 f4 ff ff       	jmp    80107238 <alltraps>

80107d82 <vector140>:
.globl vector140
vector140:
  pushl $0
80107d82:	6a 00                	push   $0x0
  pushl $140
80107d84:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107d89:	e9 aa f4 ff ff       	jmp    80107238 <alltraps>

80107d8e <vector141>:
.globl vector141
vector141:
  pushl $0
80107d8e:	6a 00                	push   $0x0
  pushl $141
80107d90:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107d95:	e9 9e f4 ff ff       	jmp    80107238 <alltraps>

80107d9a <vector142>:
.globl vector142
vector142:
  pushl $0
80107d9a:	6a 00                	push   $0x0
  pushl $142
80107d9c:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107da1:	e9 92 f4 ff ff       	jmp    80107238 <alltraps>

80107da6 <vector143>:
.globl vector143
vector143:
  pushl $0
80107da6:	6a 00                	push   $0x0
  pushl $143
80107da8:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107dad:	e9 86 f4 ff ff       	jmp    80107238 <alltraps>

80107db2 <vector144>:
.globl vector144
vector144:
  pushl $0
80107db2:	6a 00                	push   $0x0
  pushl $144
80107db4:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107db9:	e9 7a f4 ff ff       	jmp    80107238 <alltraps>

80107dbe <vector145>:
.globl vector145
vector145:
  pushl $0
80107dbe:	6a 00                	push   $0x0
  pushl $145
80107dc0:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107dc5:	e9 6e f4 ff ff       	jmp    80107238 <alltraps>

80107dca <vector146>:
.globl vector146
vector146:
  pushl $0
80107dca:	6a 00                	push   $0x0
  pushl $146
80107dcc:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107dd1:	e9 62 f4 ff ff       	jmp    80107238 <alltraps>

80107dd6 <vector147>:
.globl vector147
vector147:
  pushl $0
80107dd6:	6a 00                	push   $0x0
  pushl $147
80107dd8:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107ddd:	e9 56 f4 ff ff       	jmp    80107238 <alltraps>

80107de2 <vector148>:
.globl vector148
vector148:
  pushl $0
80107de2:	6a 00                	push   $0x0
  pushl $148
80107de4:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107de9:	e9 4a f4 ff ff       	jmp    80107238 <alltraps>

80107dee <vector149>:
.globl vector149
vector149:
  pushl $0
80107dee:	6a 00                	push   $0x0
  pushl $149
80107df0:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107df5:	e9 3e f4 ff ff       	jmp    80107238 <alltraps>

80107dfa <vector150>:
.globl vector150
vector150:
  pushl $0
80107dfa:	6a 00                	push   $0x0
  pushl $150
80107dfc:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107e01:	e9 32 f4 ff ff       	jmp    80107238 <alltraps>

80107e06 <vector151>:
.globl vector151
vector151:
  pushl $0
80107e06:	6a 00                	push   $0x0
  pushl $151
80107e08:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107e0d:	e9 26 f4 ff ff       	jmp    80107238 <alltraps>

80107e12 <vector152>:
.globl vector152
vector152:
  pushl $0
80107e12:	6a 00                	push   $0x0
  pushl $152
80107e14:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107e19:	e9 1a f4 ff ff       	jmp    80107238 <alltraps>

80107e1e <vector153>:
.globl vector153
vector153:
  pushl $0
80107e1e:	6a 00                	push   $0x0
  pushl $153
80107e20:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107e25:	e9 0e f4 ff ff       	jmp    80107238 <alltraps>

80107e2a <vector154>:
.globl vector154
vector154:
  pushl $0
80107e2a:	6a 00                	push   $0x0
  pushl $154
80107e2c:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107e31:	e9 02 f4 ff ff       	jmp    80107238 <alltraps>

80107e36 <vector155>:
.globl vector155
vector155:
  pushl $0
80107e36:	6a 00                	push   $0x0
  pushl $155
80107e38:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107e3d:	e9 f6 f3 ff ff       	jmp    80107238 <alltraps>

80107e42 <vector156>:
.globl vector156
vector156:
  pushl $0
80107e42:	6a 00                	push   $0x0
  pushl $156
80107e44:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107e49:	e9 ea f3 ff ff       	jmp    80107238 <alltraps>

80107e4e <vector157>:
.globl vector157
vector157:
  pushl $0
80107e4e:	6a 00                	push   $0x0
  pushl $157
80107e50:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107e55:	e9 de f3 ff ff       	jmp    80107238 <alltraps>

80107e5a <vector158>:
.globl vector158
vector158:
  pushl $0
80107e5a:	6a 00                	push   $0x0
  pushl $158
80107e5c:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107e61:	e9 d2 f3 ff ff       	jmp    80107238 <alltraps>

80107e66 <vector159>:
.globl vector159
vector159:
  pushl $0
80107e66:	6a 00                	push   $0x0
  pushl $159
80107e68:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107e6d:	e9 c6 f3 ff ff       	jmp    80107238 <alltraps>

80107e72 <vector160>:
.globl vector160
vector160:
  pushl $0
80107e72:	6a 00                	push   $0x0
  pushl $160
80107e74:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107e79:	e9 ba f3 ff ff       	jmp    80107238 <alltraps>

80107e7e <vector161>:
.globl vector161
vector161:
  pushl $0
80107e7e:	6a 00                	push   $0x0
  pushl $161
80107e80:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107e85:	e9 ae f3 ff ff       	jmp    80107238 <alltraps>

80107e8a <vector162>:
.globl vector162
vector162:
  pushl $0
80107e8a:	6a 00                	push   $0x0
  pushl $162
80107e8c:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107e91:	e9 a2 f3 ff ff       	jmp    80107238 <alltraps>

80107e96 <vector163>:
.globl vector163
vector163:
  pushl $0
80107e96:	6a 00                	push   $0x0
  pushl $163
80107e98:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107e9d:	e9 96 f3 ff ff       	jmp    80107238 <alltraps>

80107ea2 <vector164>:
.globl vector164
vector164:
  pushl $0
80107ea2:	6a 00                	push   $0x0
  pushl $164
80107ea4:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107ea9:	e9 8a f3 ff ff       	jmp    80107238 <alltraps>

80107eae <vector165>:
.globl vector165
vector165:
  pushl $0
80107eae:	6a 00                	push   $0x0
  pushl $165
80107eb0:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107eb5:	e9 7e f3 ff ff       	jmp    80107238 <alltraps>

80107eba <vector166>:
.globl vector166
vector166:
  pushl $0
80107eba:	6a 00                	push   $0x0
  pushl $166
80107ebc:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107ec1:	e9 72 f3 ff ff       	jmp    80107238 <alltraps>

80107ec6 <vector167>:
.globl vector167
vector167:
  pushl $0
80107ec6:	6a 00                	push   $0x0
  pushl $167
80107ec8:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107ecd:	e9 66 f3 ff ff       	jmp    80107238 <alltraps>

80107ed2 <vector168>:
.globl vector168
vector168:
  pushl $0
80107ed2:	6a 00                	push   $0x0
  pushl $168
80107ed4:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107ed9:	e9 5a f3 ff ff       	jmp    80107238 <alltraps>

80107ede <vector169>:
.globl vector169
vector169:
  pushl $0
80107ede:	6a 00                	push   $0x0
  pushl $169
80107ee0:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107ee5:	e9 4e f3 ff ff       	jmp    80107238 <alltraps>

80107eea <vector170>:
.globl vector170
vector170:
  pushl $0
80107eea:	6a 00                	push   $0x0
  pushl $170
80107eec:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107ef1:	e9 42 f3 ff ff       	jmp    80107238 <alltraps>

80107ef6 <vector171>:
.globl vector171
vector171:
  pushl $0
80107ef6:	6a 00                	push   $0x0
  pushl $171
80107ef8:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107efd:	e9 36 f3 ff ff       	jmp    80107238 <alltraps>

80107f02 <vector172>:
.globl vector172
vector172:
  pushl $0
80107f02:	6a 00                	push   $0x0
  pushl $172
80107f04:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107f09:	e9 2a f3 ff ff       	jmp    80107238 <alltraps>

80107f0e <vector173>:
.globl vector173
vector173:
  pushl $0
80107f0e:	6a 00                	push   $0x0
  pushl $173
80107f10:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107f15:	e9 1e f3 ff ff       	jmp    80107238 <alltraps>

80107f1a <vector174>:
.globl vector174
vector174:
  pushl $0
80107f1a:	6a 00                	push   $0x0
  pushl $174
80107f1c:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107f21:	e9 12 f3 ff ff       	jmp    80107238 <alltraps>

80107f26 <vector175>:
.globl vector175
vector175:
  pushl $0
80107f26:	6a 00                	push   $0x0
  pushl $175
80107f28:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107f2d:	e9 06 f3 ff ff       	jmp    80107238 <alltraps>

80107f32 <vector176>:
.globl vector176
vector176:
  pushl $0
80107f32:	6a 00                	push   $0x0
  pushl $176
80107f34:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107f39:	e9 fa f2 ff ff       	jmp    80107238 <alltraps>

80107f3e <vector177>:
.globl vector177
vector177:
  pushl $0
80107f3e:	6a 00                	push   $0x0
  pushl $177
80107f40:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107f45:	e9 ee f2 ff ff       	jmp    80107238 <alltraps>

80107f4a <vector178>:
.globl vector178
vector178:
  pushl $0
80107f4a:	6a 00                	push   $0x0
  pushl $178
80107f4c:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107f51:	e9 e2 f2 ff ff       	jmp    80107238 <alltraps>

80107f56 <vector179>:
.globl vector179
vector179:
  pushl $0
80107f56:	6a 00                	push   $0x0
  pushl $179
80107f58:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107f5d:	e9 d6 f2 ff ff       	jmp    80107238 <alltraps>

80107f62 <vector180>:
.globl vector180
vector180:
  pushl $0
80107f62:	6a 00                	push   $0x0
  pushl $180
80107f64:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107f69:	e9 ca f2 ff ff       	jmp    80107238 <alltraps>

80107f6e <vector181>:
.globl vector181
vector181:
  pushl $0
80107f6e:	6a 00                	push   $0x0
  pushl $181
80107f70:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107f75:	e9 be f2 ff ff       	jmp    80107238 <alltraps>

80107f7a <vector182>:
.globl vector182
vector182:
  pushl $0
80107f7a:	6a 00                	push   $0x0
  pushl $182
80107f7c:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107f81:	e9 b2 f2 ff ff       	jmp    80107238 <alltraps>

80107f86 <vector183>:
.globl vector183
vector183:
  pushl $0
80107f86:	6a 00                	push   $0x0
  pushl $183
80107f88:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107f8d:	e9 a6 f2 ff ff       	jmp    80107238 <alltraps>

80107f92 <vector184>:
.globl vector184
vector184:
  pushl $0
80107f92:	6a 00                	push   $0x0
  pushl $184
80107f94:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107f99:	e9 9a f2 ff ff       	jmp    80107238 <alltraps>

80107f9e <vector185>:
.globl vector185
vector185:
  pushl $0
80107f9e:	6a 00                	push   $0x0
  pushl $185
80107fa0:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107fa5:	e9 8e f2 ff ff       	jmp    80107238 <alltraps>

80107faa <vector186>:
.globl vector186
vector186:
  pushl $0
80107faa:	6a 00                	push   $0x0
  pushl $186
80107fac:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107fb1:	e9 82 f2 ff ff       	jmp    80107238 <alltraps>

80107fb6 <vector187>:
.globl vector187
vector187:
  pushl $0
80107fb6:	6a 00                	push   $0x0
  pushl $187
80107fb8:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107fbd:	e9 76 f2 ff ff       	jmp    80107238 <alltraps>

80107fc2 <vector188>:
.globl vector188
vector188:
  pushl $0
80107fc2:	6a 00                	push   $0x0
  pushl $188
80107fc4:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107fc9:	e9 6a f2 ff ff       	jmp    80107238 <alltraps>

80107fce <vector189>:
.globl vector189
vector189:
  pushl $0
80107fce:	6a 00                	push   $0x0
  pushl $189
80107fd0:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107fd5:	e9 5e f2 ff ff       	jmp    80107238 <alltraps>

80107fda <vector190>:
.globl vector190
vector190:
  pushl $0
80107fda:	6a 00                	push   $0x0
  pushl $190
80107fdc:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107fe1:	e9 52 f2 ff ff       	jmp    80107238 <alltraps>

80107fe6 <vector191>:
.globl vector191
vector191:
  pushl $0
80107fe6:	6a 00                	push   $0x0
  pushl $191
80107fe8:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107fed:	e9 46 f2 ff ff       	jmp    80107238 <alltraps>

80107ff2 <vector192>:
.globl vector192
vector192:
  pushl $0
80107ff2:	6a 00                	push   $0x0
  pushl $192
80107ff4:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107ff9:	e9 3a f2 ff ff       	jmp    80107238 <alltraps>

80107ffe <vector193>:
.globl vector193
vector193:
  pushl $0
80107ffe:	6a 00                	push   $0x0
  pushl $193
80108000:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108005:	e9 2e f2 ff ff       	jmp    80107238 <alltraps>

8010800a <vector194>:
.globl vector194
vector194:
  pushl $0
8010800a:	6a 00                	push   $0x0
  pushl $194
8010800c:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108011:	e9 22 f2 ff ff       	jmp    80107238 <alltraps>

80108016 <vector195>:
.globl vector195
vector195:
  pushl $0
80108016:	6a 00                	push   $0x0
  pushl $195
80108018:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010801d:	e9 16 f2 ff ff       	jmp    80107238 <alltraps>

80108022 <vector196>:
.globl vector196
vector196:
  pushl $0
80108022:	6a 00                	push   $0x0
  pushl $196
80108024:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80108029:	e9 0a f2 ff ff       	jmp    80107238 <alltraps>

8010802e <vector197>:
.globl vector197
vector197:
  pushl $0
8010802e:	6a 00                	push   $0x0
  pushl $197
80108030:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108035:	e9 fe f1 ff ff       	jmp    80107238 <alltraps>

8010803a <vector198>:
.globl vector198
vector198:
  pushl $0
8010803a:	6a 00                	push   $0x0
  pushl $198
8010803c:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108041:	e9 f2 f1 ff ff       	jmp    80107238 <alltraps>

80108046 <vector199>:
.globl vector199
vector199:
  pushl $0
80108046:	6a 00                	push   $0x0
  pushl $199
80108048:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010804d:	e9 e6 f1 ff ff       	jmp    80107238 <alltraps>

80108052 <vector200>:
.globl vector200
vector200:
  pushl $0
80108052:	6a 00                	push   $0x0
  pushl $200
80108054:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108059:	e9 da f1 ff ff       	jmp    80107238 <alltraps>

8010805e <vector201>:
.globl vector201
vector201:
  pushl $0
8010805e:	6a 00                	push   $0x0
  pushl $201
80108060:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108065:	e9 ce f1 ff ff       	jmp    80107238 <alltraps>

8010806a <vector202>:
.globl vector202
vector202:
  pushl $0
8010806a:	6a 00                	push   $0x0
  pushl $202
8010806c:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108071:	e9 c2 f1 ff ff       	jmp    80107238 <alltraps>

80108076 <vector203>:
.globl vector203
vector203:
  pushl $0
80108076:	6a 00                	push   $0x0
  pushl $203
80108078:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
8010807d:	e9 b6 f1 ff ff       	jmp    80107238 <alltraps>

80108082 <vector204>:
.globl vector204
vector204:
  pushl $0
80108082:	6a 00                	push   $0x0
  pushl $204
80108084:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108089:	e9 aa f1 ff ff       	jmp    80107238 <alltraps>

8010808e <vector205>:
.globl vector205
vector205:
  pushl $0
8010808e:	6a 00                	push   $0x0
  pushl $205
80108090:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108095:	e9 9e f1 ff ff       	jmp    80107238 <alltraps>

8010809a <vector206>:
.globl vector206
vector206:
  pushl $0
8010809a:	6a 00                	push   $0x0
  pushl $206
8010809c:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801080a1:	e9 92 f1 ff ff       	jmp    80107238 <alltraps>

801080a6 <vector207>:
.globl vector207
vector207:
  pushl $0
801080a6:	6a 00                	push   $0x0
  pushl $207
801080a8:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801080ad:	e9 86 f1 ff ff       	jmp    80107238 <alltraps>

801080b2 <vector208>:
.globl vector208
vector208:
  pushl $0
801080b2:	6a 00                	push   $0x0
  pushl $208
801080b4:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801080b9:	e9 7a f1 ff ff       	jmp    80107238 <alltraps>

801080be <vector209>:
.globl vector209
vector209:
  pushl $0
801080be:	6a 00                	push   $0x0
  pushl $209
801080c0:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801080c5:	e9 6e f1 ff ff       	jmp    80107238 <alltraps>

801080ca <vector210>:
.globl vector210
vector210:
  pushl $0
801080ca:	6a 00                	push   $0x0
  pushl $210
801080cc:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801080d1:	e9 62 f1 ff ff       	jmp    80107238 <alltraps>

801080d6 <vector211>:
.globl vector211
vector211:
  pushl $0
801080d6:	6a 00                	push   $0x0
  pushl $211
801080d8:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801080dd:	e9 56 f1 ff ff       	jmp    80107238 <alltraps>

801080e2 <vector212>:
.globl vector212
vector212:
  pushl $0
801080e2:	6a 00                	push   $0x0
  pushl $212
801080e4:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801080e9:	e9 4a f1 ff ff       	jmp    80107238 <alltraps>

801080ee <vector213>:
.globl vector213
vector213:
  pushl $0
801080ee:	6a 00                	push   $0x0
  pushl $213
801080f0:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801080f5:	e9 3e f1 ff ff       	jmp    80107238 <alltraps>

801080fa <vector214>:
.globl vector214
vector214:
  pushl $0
801080fa:	6a 00                	push   $0x0
  pushl $214
801080fc:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108101:	e9 32 f1 ff ff       	jmp    80107238 <alltraps>

80108106 <vector215>:
.globl vector215
vector215:
  pushl $0
80108106:	6a 00                	push   $0x0
  pushl $215
80108108:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010810d:	e9 26 f1 ff ff       	jmp    80107238 <alltraps>

80108112 <vector216>:
.globl vector216
vector216:
  pushl $0
80108112:	6a 00                	push   $0x0
  pushl $216
80108114:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80108119:	e9 1a f1 ff ff       	jmp    80107238 <alltraps>

8010811e <vector217>:
.globl vector217
vector217:
  pushl $0
8010811e:	6a 00                	push   $0x0
  pushl $217
80108120:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108125:	e9 0e f1 ff ff       	jmp    80107238 <alltraps>

8010812a <vector218>:
.globl vector218
vector218:
  pushl $0
8010812a:	6a 00                	push   $0x0
  pushl $218
8010812c:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108131:	e9 02 f1 ff ff       	jmp    80107238 <alltraps>

80108136 <vector219>:
.globl vector219
vector219:
  pushl $0
80108136:	6a 00                	push   $0x0
  pushl $219
80108138:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010813d:	e9 f6 f0 ff ff       	jmp    80107238 <alltraps>

80108142 <vector220>:
.globl vector220
vector220:
  pushl $0
80108142:	6a 00                	push   $0x0
  pushl $220
80108144:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108149:	e9 ea f0 ff ff       	jmp    80107238 <alltraps>

8010814e <vector221>:
.globl vector221
vector221:
  pushl $0
8010814e:	6a 00                	push   $0x0
  pushl $221
80108150:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108155:	e9 de f0 ff ff       	jmp    80107238 <alltraps>

8010815a <vector222>:
.globl vector222
vector222:
  pushl $0
8010815a:	6a 00                	push   $0x0
  pushl $222
8010815c:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108161:	e9 d2 f0 ff ff       	jmp    80107238 <alltraps>

80108166 <vector223>:
.globl vector223
vector223:
  pushl $0
80108166:	6a 00                	push   $0x0
  pushl $223
80108168:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
8010816d:	e9 c6 f0 ff ff       	jmp    80107238 <alltraps>

80108172 <vector224>:
.globl vector224
vector224:
  pushl $0
80108172:	6a 00                	push   $0x0
  pushl $224
80108174:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108179:	e9 ba f0 ff ff       	jmp    80107238 <alltraps>

8010817e <vector225>:
.globl vector225
vector225:
  pushl $0
8010817e:	6a 00                	push   $0x0
  pushl $225
80108180:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108185:	e9 ae f0 ff ff       	jmp    80107238 <alltraps>

8010818a <vector226>:
.globl vector226
vector226:
  pushl $0
8010818a:	6a 00                	push   $0x0
  pushl $226
8010818c:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108191:	e9 a2 f0 ff ff       	jmp    80107238 <alltraps>

80108196 <vector227>:
.globl vector227
vector227:
  pushl $0
80108196:	6a 00                	push   $0x0
  pushl $227
80108198:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
8010819d:	e9 96 f0 ff ff       	jmp    80107238 <alltraps>

801081a2 <vector228>:
.globl vector228
vector228:
  pushl $0
801081a2:	6a 00                	push   $0x0
  pushl $228
801081a4:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801081a9:	e9 8a f0 ff ff       	jmp    80107238 <alltraps>

801081ae <vector229>:
.globl vector229
vector229:
  pushl $0
801081ae:	6a 00                	push   $0x0
  pushl $229
801081b0:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801081b5:	e9 7e f0 ff ff       	jmp    80107238 <alltraps>

801081ba <vector230>:
.globl vector230
vector230:
  pushl $0
801081ba:	6a 00                	push   $0x0
  pushl $230
801081bc:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801081c1:	e9 72 f0 ff ff       	jmp    80107238 <alltraps>

801081c6 <vector231>:
.globl vector231
vector231:
  pushl $0
801081c6:	6a 00                	push   $0x0
  pushl $231
801081c8:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801081cd:	e9 66 f0 ff ff       	jmp    80107238 <alltraps>

801081d2 <vector232>:
.globl vector232
vector232:
  pushl $0
801081d2:	6a 00                	push   $0x0
  pushl $232
801081d4:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801081d9:	e9 5a f0 ff ff       	jmp    80107238 <alltraps>

801081de <vector233>:
.globl vector233
vector233:
  pushl $0
801081de:	6a 00                	push   $0x0
  pushl $233
801081e0:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801081e5:	e9 4e f0 ff ff       	jmp    80107238 <alltraps>

801081ea <vector234>:
.globl vector234
vector234:
  pushl $0
801081ea:	6a 00                	push   $0x0
  pushl $234
801081ec:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801081f1:	e9 42 f0 ff ff       	jmp    80107238 <alltraps>

801081f6 <vector235>:
.globl vector235
vector235:
  pushl $0
801081f6:	6a 00                	push   $0x0
  pushl $235
801081f8:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801081fd:	e9 36 f0 ff ff       	jmp    80107238 <alltraps>

80108202 <vector236>:
.globl vector236
vector236:
  pushl $0
80108202:	6a 00                	push   $0x0
  pushl $236
80108204:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80108209:	e9 2a f0 ff ff       	jmp    80107238 <alltraps>

8010820e <vector237>:
.globl vector237
vector237:
  pushl $0
8010820e:	6a 00                	push   $0x0
  pushl $237
80108210:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108215:	e9 1e f0 ff ff       	jmp    80107238 <alltraps>

8010821a <vector238>:
.globl vector238
vector238:
  pushl $0
8010821a:	6a 00                	push   $0x0
  pushl $238
8010821c:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108221:	e9 12 f0 ff ff       	jmp    80107238 <alltraps>

80108226 <vector239>:
.globl vector239
vector239:
  pushl $0
80108226:	6a 00                	push   $0x0
  pushl $239
80108228:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010822d:	e9 06 f0 ff ff       	jmp    80107238 <alltraps>

80108232 <vector240>:
.globl vector240
vector240:
  pushl $0
80108232:	6a 00                	push   $0x0
  pushl $240
80108234:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108239:	e9 fa ef ff ff       	jmp    80107238 <alltraps>

8010823e <vector241>:
.globl vector241
vector241:
  pushl $0
8010823e:	6a 00                	push   $0x0
  pushl $241
80108240:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108245:	e9 ee ef ff ff       	jmp    80107238 <alltraps>

8010824a <vector242>:
.globl vector242
vector242:
  pushl $0
8010824a:	6a 00                	push   $0x0
  pushl $242
8010824c:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108251:	e9 e2 ef ff ff       	jmp    80107238 <alltraps>

80108256 <vector243>:
.globl vector243
vector243:
  pushl $0
80108256:	6a 00                	push   $0x0
  pushl $243
80108258:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010825d:	e9 d6 ef ff ff       	jmp    80107238 <alltraps>

80108262 <vector244>:
.globl vector244
vector244:
  pushl $0
80108262:	6a 00                	push   $0x0
  pushl $244
80108264:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108269:	e9 ca ef ff ff       	jmp    80107238 <alltraps>

8010826e <vector245>:
.globl vector245
vector245:
  pushl $0
8010826e:	6a 00                	push   $0x0
  pushl $245
80108270:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108275:	e9 be ef ff ff       	jmp    80107238 <alltraps>

8010827a <vector246>:
.globl vector246
vector246:
  pushl $0
8010827a:	6a 00                	push   $0x0
  pushl $246
8010827c:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108281:	e9 b2 ef ff ff       	jmp    80107238 <alltraps>

80108286 <vector247>:
.globl vector247
vector247:
  pushl $0
80108286:	6a 00                	push   $0x0
  pushl $247
80108288:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010828d:	e9 a6 ef ff ff       	jmp    80107238 <alltraps>

80108292 <vector248>:
.globl vector248
vector248:
  pushl $0
80108292:	6a 00                	push   $0x0
  pushl $248
80108294:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108299:	e9 9a ef ff ff       	jmp    80107238 <alltraps>

8010829e <vector249>:
.globl vector249
vector249:
  pushl $0
8010829e:	6a 00                	push   $0x0
  pushl $249
801082a0:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801082a5:	e9 8e ef ff ff       	jmp    80107238 <alltraps>

801082aa <vector250>:
.globl vector250
vector250:
  pushl $0
801082aa:	6a 00                	push   $0x0
  pushl $250
801082ac:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801082b1:	e9 82 ef ff ff       	jmp    80107238 <alltraps>

801082b6 <vector251>:
.globl vector251
vector251:
  pushl $0
801082b6:	6a 00                	push   $0x0
  pushl $251
801082b8:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801082bd:	e9 76 ef ff ff       	jmp    80107238 <alltraps>

801082c2 <vector252>:
.globl vector252
vector252:
  pushl $0
801082c2:	6a 00                	push   $0x0
  pushl $252
801082c4:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801082c9:	e9 6a ef ff ff       	jmp    80107238 <alltraps>

801082ce <vector253>:
.globl vector253
vector253:
  pushl $0
801082ce:	6a 00                	push   $0x0
  pushl $253
801082d0:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801082d5:	e9 5e ef ff ff       	jmp    80107238 <alltraps>

801082da <vector254>:
.globl vector254
vector254:
  pushl $0
801082da:	6a 00                	push   $0x0
  pushl $254
801082dc:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801082e1:	e9 52 ef ff ff       	jmp    80107238 <alltraps>

801082e6 <vector255>:
.globl vector255
vector255:
  pushl $0
801082e6:	6a 00                	push   $0x0
  pushl $255
801082e8:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801082ed:	e9 46 ef ff ff       	jmp    80107238 <alltraps>
	...

801082f4 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801082f4:	55                   	push   %ebp
801082f5:	89 e5                	mov    %esp,%ebp
801082f7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801082fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801082fd:	48                   	dec    %eax
801082fe:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108302:	8b 45 08             	mov    0x8(%ebp),%eax
80108305:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108309:	8b 45 08             	mov    0x8(%ebp),%eax
8010830c:	c1 e8 10             	shr    $0x10,%eax
8010830f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108313:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108316:	0f 01 10             	lgdtl  (%eax)
}
80108319:	c9                   	leave  
8010831a:	c3                   	ret    

8010831b <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010831b:	55                   	push   %ebp
8010831c:	89 e5                	mov    %esp,%ebp
8010831e:	83 ec 04             	sub    $0x4,%esp
80108321:	8b 45 08             	mov    0x8(%ebp),%eax
80108324:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108328:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010832b:	0f 00 d8             	ltr    %ax
}
8010832e:	c9                   	leave  
8010832f:	c3                   	ret    

80108330 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80108330:	55                   	push   %ebp
80108331:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108333:	8b 45 08             	mov    0x8(%ebp),%eax
80108336:	0f 22 d8             	mov    %eax,%cr3
}
80108339:	5d                   	pop    %ebp
8010833a:	c3                   	ret    

8010833b <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010833b:	55                   	push   %ebp
8010833c:	89 e5                	mov    %esp,%ebp
8010833e:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80108341:	e8 24 c1 ff ff       	call   8010446a <cpuid>
80108346:	89 c2                	mov    %eax,%edx
80108348:	89 d0                	mov    %edx,%eax
8010834a:	c1 e0 02             	shl    $0x2,%eax
8010834d:	01 d0                	add    %edx,%eax
8010834f:	01 c0                	add    %eax,%eax
80108351:	01 d0                	add    %edx,%eax
80108353:	c1 e0 04             	shl    $0x4,%eax
80108356:	05 c0 5c 11 80       	add    $0x80115cc0,%eax
8010835b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010835e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108361:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108367:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836a:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108370:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108373:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837a:	8a 50 7d             	mov    0x7d(%eax),%dl
8010837d:	83 e2 f0             	and    $0xfffffff0,%edx
80108380:	83 ca 0a             	or     $0xa,%edx
80108383:	88 50 7d             	mov    %dl,0x7d(%eax)
80108386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108389:	8a 50 7d             	mov    0x7d(%eax),%dl
8010838c:	83 ca 10             	or     $0x10,%edx
8010838f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108395:	8a 50 7d             	mov    0x7d(%eax),%dl
80108398:	83 e2 9f             	and    $0xffffff9f,%edx
8010839b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010839e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a1:	8a 50 7d             	mov    0x7d(%eax),%dl
801083a4:	83 ca 80             	or     $0xffffff80,%edx
801083a7:	88 50 7d             	mov    %dl,0x7d(%eax)
801083aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ad:	8a 50 7e             	mov    0x7e(%eax),%dl
801083b0:	83 ca 0f             	or     $0xf,%edx
801083b3:	88 50 7e             	mov    %dl,0x7e(%eax)
801083b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b9:	8a 50 7e             	mov    0x7e(%eax),%dl
801083bc:	83 e2 ef             	and    $0xffffffef,%edx
801083bf:	88 50 7e             	mov    %dl,0x7e(%eax)
801083c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c5:	8a 50 7e             	mov    0x7e(%eax),%dl
801083c8:	83 e2 df             	and    $0xffffffdf,%edx
801083cb:	88 50 7e             	mov    %dl,0x7e(%eax)
801083ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d1:	8a 50 7e             	mov    0x7e(%eax),%dl
801083d4:	83 ca 40             	or     $0x40,%edx
801083d7:	88 50 7e             	mov    %dl,0x7e(%eax)
801083da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083dd:	8a 50 7e             	mov    0x7e(%eax),%dl
801083e0:	83 ca 80             	or     $0xffffff80,%edx
801083e3:	88 50 7e             	mov    %dl,0x7e(%eax)
801083e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e9:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801083ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f0:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801083f7:	ff ff 
801083f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fc:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108403:	00 00 
80108405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108408:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010840f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108412:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108418:	83 e2 f0             	and    $0xfffffff0,%edx
8010841b:	83 ca 02             	or     $0x2,%edx
8010841e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108424:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108427:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010842d:	83 ca 10             	or     $0x10,%edx
80108430:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108439:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010843f:	83 e2 9f             	and    $0xffffff9f,%edx
80108442:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108448:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844b:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108451:	83 ca 80             	or     $0xffffff80,%edx
80108454:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010845a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108463:	83 ca 0f             	or     $0xf,%edx
80108466:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010846c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846f:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108475:	83 e2 ef             	and    $0xffffffef,%edx
80108478:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010847e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108481:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108487:	83 e2 df             	and    $0xffffffdf,%edx
8010848a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108493:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108499:	83 ca 40             	or     $0x40,%edx
8010849c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a5:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801084ab:	83 ca 80             	or     $0xffffff80,%edx
801084ae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801084b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b7:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801084be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c1:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801084c8:	ff ff 
801084ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cd:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801084d4:	00 00 
801084d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d9:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801084e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e3:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801084e9:	83 e2 f0             	and    $0xfffffff0,%edx
801084ec:	83 ca 0a             	or     $0xa,%edx
801084ef:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801084f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f8:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801084fe:	83 ca 10             	or     $0x10,%edx
80108501:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108507:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850a:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108510:	83 ca 60             	or     $0x60,%edx
80108513:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108519:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851c:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108522:	83 ca 80             	or     $0xffffff80,%edx
80108525:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010852b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108534:	83 ca 0f             	or     $0xf,%edx
80108537:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010853d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108540:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108546:	83 e2 ef             	and    $0xffffffef,%edx
80108549:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010854f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108552:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108558:	83 e2 df             	and    $0xffffffdf,%edx
8010855b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108561:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108564:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010856a:	83 ca 40             	or     $0x40,%edx
8010856d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108576:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010857c:	83 ca 80             	or     $0xffffff80,%edx
8010857f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108588:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010858f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108592:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108599:	ff ff 
8010859b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859e:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801085a5:	00 00 
801085a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085aa:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801085b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b4:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801085ba:	83 e2 f0             	and    $0xfffffff0,%edx
801085bd:	83 ca 02             	or     $0x2,%edx
801085c0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801085c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c9:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801085cf:	83 ca 10             	or     $0x10,%edx
801085d2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801085d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085db:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801085e1:	83 ca 60             	or     $0x60,%edx
801085e4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801085ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ed:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801085f3:	83 ca 80             	or     $0xffffff80,%edx
801085f6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801085fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ff:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108605:	83 ca 0f             	or     $0xf,%edx
80108608:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010860e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108611:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108617:	83 e2 ef             	and    $0xffffffef,%edx
8010861a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108623:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108629:	83 e2 df             	and    $0xffffffdf,%edx
8010862c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108635:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010863b:	83 ca 40             	or     $0x40,%edx
8010863e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108647:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010864d:	83 ca 80             	or     $0xffffff80,%edx
80108650:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108656:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108659:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108660:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108663:	83 c0 70             	add    $0x70,%eax
80108666:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
8010866d:	00 
8010866e:	89 04 24             	mov    %eax,(%esp)
80108671:	e8 7e fc ff ff       	call   801082f4 <lgdt>
}
80108676:	c9                   	leave  
80108677:	c3                   	ret    

80108678 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108678:	55                   	push   %ebp
80108679:	89 e5                	mov    %esp,%ebp
8010867b:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010867e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108681:	c1 e8 16             	shr    $0x16,%eax
80108684:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010868b:	8b 45 08             	mov    0x8(%ebp),%eax
8010868e:	01 d0                	add    %edx,%eax
80108690:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108693:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108696:	8b 00                	mov    (%eax),%eax
80108698:	83 e0 01             	and    $0x1,%eax
8010869b:	85 c0                	test   %eax,%eax
8010869d:	74 14                	je     801086b3 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010869f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a2:	8b 00                	mov    (%eax),%eax
801086a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086a9:	05 00 00 00 80       	add    $0x80000000,%eax
801086ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
801086b1:	eb 48                	jmp    801086fb <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801086b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801086b7:	74 0e                	je     801086c7 <walkpgdir+0x4f>
801086b9:	e8 ce a7 ff ff       	call   80102e8c <kalloc>
801086be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801086c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801086c5:	75 07                	jne    801086ce <walkpgdir+0x56>
      return 0;
801086c7:	b8 00 00 00 00       	mov    $0x0,%eax
801086cc:	eb 44                	jmp    80108712 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801086ce:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086d5:	00 
801086d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801086dd:	00 
801086de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e1:	89 04 24             	mov    %eax,(%esp)
801086e4:	e8 19 d0 ff ff       	call   80105702 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801086e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ec:	05 00 00 00 80       	add    $0x80000000,%eax
801086f1:	83 c8 07             	or     $0x7,%eax
801086f4:	89 c2                	mov    %eax,%edx
801086f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086f9:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801086fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801086fe:	c1 e8 0c             	shr    $0xc,%eax
80108701:	25 ff 03 00 00       	and    $0x3ff,%eax
80108706:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010870d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108710:	01 d0                	add    %edx,%eax
}
80108712:	c9                   	leave  
80108713:	c3                   	ret    

80108714 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108714:	55                   	push   %ebp
80108715:	89 e5                	mov    %esp,%ebp
80108717:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010871a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010871d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108722:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108725:	8b 55 0c             	mov    0xc(%ebp),%edx
80108728:	8b 45 10             	mov    0x10(%ebp),%eax
8010872b:	01 d0                	add    %edx,%eax
8010872d:	48                   	dec    %eax
8010872e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108733:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108736:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010873d:	00 
8010873e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108741:	89 44 24 04          	mov    %eax,0x4(%esp)
80108745:	8b 45 08             	mov    0x8(%ebp),%eax
80108748:	89 04 24             	mov    %eax,(%esp)
8010874b:	e8 28 ff ff ff       	call   80108678 <walkpgdir>
80108750:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108753:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108757:	75 07                	jne    80108760 <mappages+0x4c>
      return -1;
80108759:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010875e:	eb 48                	jmp    801087a8 <mappages+0x94>
    if(*pte & PTE_P)
80108760:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108763:	8b 00                	mov    (%eax),%eax
80108765:	83 e0 01             	and    $0x1,%eax
80108768:	85 c0                	test   %eax,%eax
8010876a:	74 0c                	je     80108778 <mappages+0x64>
      panic("remap");
8010876c:	c7 04 24 88 a0 10 80 	movl   $0x8010a088,(%esp)
80108773:	e8 dc 7d ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108778:	8b 45 18             	mov    0x18(%ebp),%eax
8010877b:	0b 45 14             	or     0x14(%ebp),%eax
8010877e:	83 c8 01             	or     $0x1,%eax
80108781:	89 c2                	mov    %eax,%edx
80108783:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108786:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010878b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010878e:	75 08                	jne    80108798 <mappages+0x84>
      break;
80108790:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108791:	b8 00 00 00 00       	mov    $0x0,%eax
80108796:	eb 10                	jmp    801087a8 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108798:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010879f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801087a6:	eb 8e                	jmp    80108736 <mappages+0x22>
  return 0;
}
801087a8:	c9                   	leave  
801087a9:	c3                   	ret    

801087aa <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801087aa:	55                   	push   %ebp
801087ab:	89 e5                	mov    %esp,%ebp
801087ad:	53                   	push   %ebx
801087ae:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801087b1:	e8 d6 a6 ff ff       	call   80102e8c <kalloc>
801087b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801087b9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087bd:	75 0a                	jne    801087c9 <setupkvm+0x1f>
    return 0;
801087bf:	b8 00 00 00 00       	mov    $0x0,%eax
801087c4:	e9 84 00 00 00       	jmp    8010884d <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801087c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087d0:	00 
801087d1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801087d8:	00 
801087d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087dc:	89 04 24             	mov    %eax,(%esp)
801087df:	e8 1e cf ff ff       	call   80105702 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801087e4:	c7 45 f4 20 d5 10 80 	movl   $0x8010d520,-0xc(%ebp)
801087eb:	eb 54                	jmp    80108841 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801087ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f0:	8b 48 0c             	mov    0xc(%eax),%ecx
801087f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f6:	8b 50 04             	mov    0x4(%eax),%edx
801087f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fc:	8b 58 08             	mov    0x8(%eax),%ebx
801087ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108802:	8b 40 04             	mov    0x4(%eax),%eax
80108805:	29 c3                	sub    %eax,%ebx
80108807:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880a:	8b 00                	mov    (%eax),%eax
8010880c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108810:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108814:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108818:	89 44 24 04          	mov    %eax,0x4(%esp)
8010881c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010881f:	89 04 24             	mov    %eax,(%esp)
80108822:	e8 ed fe ff ff       	call   80108714 <mappages>
80108827:	85 c0                	test   %eax,%eax
80108829:	79 12                	jns    8010883d <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
8010882b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010882e:	89 04 24             	mov    %eax,(%esp)
80108831:	e8 1a 05 00 00       	call   80108d50 <freevm>
      return 0;
80108836:	b8 00 00 00 00       	mov    $0x0,%eax
8010883b:	eb 10                	jmp    8010884d <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010883d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108841:	81 7d f4 60 d5 10 80 	cmpl   $0x8010d560,-0xc(%ebp)
80108848:	72 a3                	jb     801087ed <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
8010884a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010884d:	83 c4 34             	add    $0x34,%esp
80108850:	5b                   	pop    %ebx
80108851:	5d                   	pop    %ebp
80108852:	c3                   	ret    

80108853 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108853:	55                   	push   %ebp
80108854:	89 e5                	mov    %esp,%ebp
80108856:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108859:	e8 4c ff ff ff       	call   801087aa <setupkvm>
8010885e:	a3 e4 8b 11 80       	mov    %eax,0x80118be4
  switchkvm();
80108863:	e8 02 00 00 00       	call   8010886a <switchkvm>
}
80108868:	c9                   	leave  
80108869:	c3                   	ret    

8010886a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010886a:	55                   	push   %ebp
8010886b:	89 e5                	mov    %esp,%ebp
8010886d:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108870:	a1 e4 8b 11 80       	mov    0x80118be4,%eax
80108875:	05 00 00 00 80       	add    $0x80000000,%eax
8010887a:	89 04 24             	mov    %eax,(%esp)
8010887d:	e8 ae fa ff ff       	call   80108330 <lcr3>
}
80108882:	c9                   	leave  
80108883:	c3                   	ret    

80108884 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108884:	55                   	push   %ebp
80108885:	89 e5                	mov    %esp,%ebp
80108887:	57                   	push   %edi
80108888:	56                   	push   %esi
80108889:	53                   	push   %ebx
8010888a:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
8010888d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108891:	75 0c                	jne    8010889f <switchuvm+0x1b>
    panic("switchuvm: no process");
80108893:	c7 04 24 8e a0 10 80 	movl   $0x8010a08e,(%esp)
8010889a:	e8 b5 7c ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
8010889f:	8b 45 08             	mov    0x8(%ebp),%eax
801088a2:	8b 40 08             	mov    0x8(%eax),%eax
801088a5:	85 c0                	test   %eax,%eax
801088a7:	75 0c                	jne    801088b5 <switchuvm+0x31>
    panic("switchuvm: no kstack");
801088a9:	c7 04 24 a4 a0 10 80 	movl   $0x8010a0a4,(%esp)
801088b0:	e8 9f 7c ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801088b5:	8b 45 08             	mov    0x8(%ebp),%eax
801088b8:	8b 40 04             	mov    0x4(%eax),%eax
801088bb:	85 c0                	test   %eax,%eax
801088bd:	75 0c                	jne    801088cb <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801088bf:	c7 04 24 b9 a0 10 80 	movl   $0x8010a0b9,(%esp)
801088c6:	e8 89 7c ff ff       	call   80100554 <panic>

  pushcli();
801088cb:	e8 2e cd ff ff       	call   801055fe <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801088d0:	e8 da bb ff ff       	call   801044af <mycpu>
801088d5:	89 c3                	mov    %eax,%ebx
801088d7:	e8 d3 bb ff ff       	call   801044af <mycpu>
801088dc:	83 c0 08             	add    $0x8,%eax
801088df:	89 c6                	mov    %eax,%esi
801088e1:	e8 c9 bb ff ff       	call   801044af <mycpu>
801088e6:	83 c0 08             	add    $0x8,%eax
801088e9:	c1 e8 10             	shr    $0x10,%eax
801088ec:	89 c7                	mov    %eax,%edi
801088ee:	e8 bc bb ff ff       	call   801044af <mycpu>
801088f3:	83 c0 08             	add    $0x8,%eax
801088f6:	c1 e8 18             	shr    $0x18,%eax
801088f9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108900:	67 00 
80108902:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108909:	89 f9                	mov    %edi,%ecx
8010890b:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108911:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108917:	83 e2 f0             	and    $0xfffffff0,%edx
8010891a:	83 ca 09             	or     $0x9,%edx
8010891d:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108923:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108929:	83 ca 10             	or     $0x10,%edx
8010892c:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108932:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108938:	83 e2 9f             	and    $0xffffff9f,%edx
8010893b:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108941:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108947:	83 ca 80             	or     $0xffffff80,%edx
8010894a:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108950:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108956:	83 e2 f0             	and    $0xfffffff0,%edx
80108959:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010895f:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108965:	83 e2 ef             	and    $0xffffffef,%edx
80108968:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010896e:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108974:	83 e2 df             	and    $0xffffffdf,%edx
80108977:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010897d:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108983:	83 ca 40             	or     $0x40,%edx
80108986:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010898c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108992:	83 e2 7f             	and    $0x7f,%edx
80108995:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010899b:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801089a1:	e8 09 bb ff ff       	call   801044af <mycpu>
801089a6:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801089ac:	83 e2 ef             	and    $0xffffffef,%edx
801089af:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801089b5:	e8 f5 ba ff ff       	call   801044af <mycpu>
801089ba:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801089c0:	e8 ea ba ff ff       	call   801044af <mycpu>
801089c5:	8b 55 08             	mov    0x8(%ebp),%edx
801089c8:	8b 52 08             	mov    0x8(%edx),%edx
801089cb:	81 c2 00 10 00 00    	add    $0x1000,%edx
801089d1:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801089d4:	e8 d6 ba ff ff       	call   801044af <mycpu>
801089d9:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801089df:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
801089e6:	e8 30 f9 ff ff       	call   8010831b <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
801089eb:	8b 45 08             	mov    0x8(%ebp),%eax
801089ee:	8b 40 04             	mov    0x4(%eax),%eax
801089f1:	05 00 00 00 80       	add    $0x80000000,%eax
801089f6:	89 04 24             	mov    %eax,(%esp)
801089f9:	e8 32 f9 ff ff       	call   80108330 <lcr3>
  popcli();
801089fe:	e8 45 cc ff ff       	call   80105648 <popcli>
}
80108a03:	83 c4 1c             	add    $0x1c,%esp
80108a06:	5b                   	pop    %ebx
80108a07:	5e                   	pop    %esi
80108a08:	5f                   	pop    %edi
80108a09:	5d                   	pop    %ebp
80108a0a:	c3                   	ret    

80108a0b <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108a0b:	55                   	push   %ebp
80108a0c:	89 e5                	mov    %esp,%ebp
80108a0e:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108a11:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108a18:	76 0c                	jbe    80108a26 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108a1a:	c7 04 24 cd a0 10 80 	movl   $0x8010a0cd,(%esp)
80108a21:	e8 2e 7b ff ff       	call   80100554 <panic>
  mem = kalloc();
80108a26:	e8 61 a4 ff ff       	call   80102e8c <kalloc>
80108a2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108a2e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108a35:	00 
80108a36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108a3d:	00 
80108a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a41:	89 04 24             	mov    %eax,(%esp)
80108a44:	e8 b9 cc ff ff       	call   80105702 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4c:	05 00 00 00 80       	add    $0x80000000,%eax
80108a51:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108a58:	00 
80108a59:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108a5d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108a64:	00 
80108a65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108a6c:	00 
80108a6d:	8b 45 08             	mov    0x8(%ebp),%eax
80108a70:	89 04 24             	mov    %eax,(%esp)
80108a73:	e8 9c fc ff ff       	call   80108714 <mappages>
  memmove(mem, init, sz);
80108a78:	8b 45 10             	mov    0x10(%ebp),%eax
80108a7b:	89 44 24 08          	mov    %eax,0x8(%esp)
80108a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a82:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a89:	89 04 24             	mov    %eax,(%esp)
80108a8c:	e8 3a cd ff ff       	call   801057cb <memmove>
}
80108a91:	c9                   	leave  
80108a92:	c3                   	ret    

80108a93 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108a93:	55                   	push   %ebp
80108a94:	89 e5                	mov    %esp,%ebp
80108a96:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108a99:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a9c:	25 ff 0f 00 00       	and    $0xfff,%eax
80108aa1:	85 c0                	test   %eax,%eax
80108aa3:	74 0c                	je     80108ab1 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108aa5:	c7 04 24 e8 a0 10 80 	movl   $0x8010a0e8,(%esp)
80108aac:	e8 a3 7a ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108ab1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ab8:	e9 a6 00 00 00       	jmp    80108b63 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac0:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ac3:	01 d0                	add    %edx,%eax
80108ac5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108acc:	00 
80108acd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ad4:	89 04 24             	mov    %eax,(%esp)
80108ad7:	e8 9c fb ff ff       	call   80108678 <walkpgdir>
80108adc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108adf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108ae3:	75 0c                	jne    80108af1 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108ae5:	c7 04 24 0b a1 10 80 	movl   $0x8010a10b,(%esp)
80108aec:	e8 63 7a ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108af4:	8b 00                	mov    (%eax),%eax
80108af6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108afb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b01:	8b 55 18             	mov    0x18(%ebp),%edx
80108b04:	29 c2                	sub    %eax,%edx
80108b06:	89 d0                	mov    %edx,%eax
80108b08:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108b0d:	77 0f                	ja     80108b1e <loaduvm+0x8b>
      n = sz - i;
80108b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b12:	8b 55 18             	mov    0x18(%ebp),%edx
80108b15:	29 c2                	sub    %eax,%edx
80108b17:	89 d0                	mov    %edx,%eax
80108b19:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b1c:	eb 07                	jmp    80108b25 <loaduvm+0x92>
    else
      n = PGSIZE;
80108b1e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b28:	8b 55 14             	mov    0x14(%ebp),%edx
80108b2b:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108b2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b31:	05 00 00 00 80       	add    $0x80000000,%eax
80108b36:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108b39:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108b3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108b41:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b45:	8b 45 10             	mov    0x10(%ebp),%eax
80108b48:	89 04 24             	mov    %eax,(%esp)
80108b4b:	e8 09 94 ff ff       	call   80101f59 <readi>
80108b50:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108b53:	74 07                	je     80108b5c <loaduvm+0xc9>
      return -1;
80108b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108b5a:	eb 18                	jmp    80108b74 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108b5c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b66:	3b 45 18             	cmp    0x18(%ebp),%eax
80108b69:	0f 82 4e ff ff ff    	jb     80108abd <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b74:	c9                   	leave  
80108b75:	c3                   	ret    

80108b76 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108b76:	55                   	push   %ebp
80108b77:	89 e5                	mov    %esp,%ebp
80108b79:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108b7c:	8b 45 10             	mov    0x10(%ebp),%eax
80108b7f:	85 c0                	test   %eax,%eax
80108b81:	79 0a                	jns    80108b8d <allocuvm+0x17>
    return 0;
80108b83:	b8 00 00 00 00       	mov    $0x0,%eax
80108b88:	e9 fd 00 00 00       	jmp    80108c8a <allocuvm+0x114>
  if(newsz < oldsz)
80108b8d:	8b 45 10             	mov    0x10(%ebp),%eax
80108b90:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b93:	73 08                	jae    80108b9d <allocuvm+0x27>
    return oldsz;
80108b95:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b98:	e9 ed 00 00 00       	jmp    80108c8a <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ba0:	05 ff 0f 00 00       	add    $0xfff,%eax
80108ba5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108baa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108bad:	e9 c9 00 00 00       	jmp    80108c7b <allocuvm+0x105>
    mem = kalloc();
80108bb2:	e8 d5 a2 ff ff       	call   80102e8c <kalloc>
80108bb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108bba:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108bbe:	75 2f                	jne    80108bef <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108bc0:	c7 04 24 29 a1 10 80 	movl   $0x8010a129,(%esp)
80108bc7:	e8 f5 77 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bcf:	89 44 24 08          	mov    %eax,0x8(%esp)
80108bd3:	8b 45 10             	mov    0x10(%ebp),%eax
80108bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bda:	8b 45 08             	mov    0x8(%ebp),%eax
80108bdd:	89 04 24             	mov    %eax,(%esp)
80108be0:	e8 a7 00 00 00       	call   80108c8c <deallocuvm>
      return 0;
80108be5:	b8 00 00 00 00       	mov    $0x0,%eax
80108bea:	e9 9b 00 00 00       	jmp    80108c8a <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108bef:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108bf6:	00 
80108bf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108bfe:	00 
80108bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c02:	89 04 24             	mov    %eax,(%esp)
80108c05:	e8 f8 ca ff ff       	call   80105702 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108c0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c0d:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c16:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108c1d:	00 
80108c1e:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108c22:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c29:	00 
80108c2a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80108c31:	89 04 24             	mov    %eax,(%esp)
80108c34:	e8 db fa ff ff       	call   80108714 <mappages>
80108c39:	85 c0                	test   %eax,%eax
80108c3b:	79 37                	jns    80108c74 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108c3d:	c7 04 24 41 a1 10 80 	movl   $0x8010a141,(%esp)
80108c44:	e8 78 77 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108c49:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c4c:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c50:	8b 45 10             	mov    0x10(%ebp),%eax
80108c53:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c57:	8b 45 08             	mov    0x8(%ebp),%eax
80108c5a:	89 04 24             	mov    %eax,(%esp)
80108c5d:	e8 2a 00 00 00       	call   80108c8c <deallocuvm>
      kfree(mem);
80108c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c65:	89 04 24             	mov    %eax,(%esp)
80108c68:	e8 42 a1 ff ff       	call   80102daf <kfree>
      return 0;
80108c6d:	b8 00 00 00 00       	mov    $0x0,%eax
80108c72:	eb 16                	jmp    80108c8a <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108c74:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c7e:	3b 45 10             	cmp    0x10(%ebp),%eax
80108c81:	0f 82 2b ff ff ff    	jb     80108bb2 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108c87:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108c8a:	c9                   	leave  
80108c8b:	c3                   	ret    

80108c8c <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108c8c:	55                   	push   %ebp
80108c8d:	89 e5                	mov    %esp,%ebp
80108c8f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108c92:	8b 45 10             	mov    0x10(%ebp),%eax
80108c95:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c98:	72 08                	jb     80108ca2 <deallocuvm+0x16>
    return oldsz;
80108c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c9d:	e9 ac 00 00 00       	jmp    80108d4e <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108ca2:	8b 45 10             	mov    0x10(%ebp),%eax
80108ca5:	05 ff 0f 00 00       	add    $0xfff,%eax
80108caa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108caf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108cb2:	e9 88 00 00 00       	jmp    80108d3f <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108cb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108cc1:	00 
80108cc2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80108cc9:	89 04 24             	mov    %eax,(%esp)
80108ccc:	e8 a7 f9 ff ff       	call   80108678 <walkpgdir>
80108cd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108cd4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108cd8:	75 14                	jne    80108cee <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cdd:	c1 e8 16             	shr    $0x16,%eax
80108ce0:	40                   	inc    %eax
80108ce1:	c1 e0 16             	shl    $0x16,%eax
80108ce4:	2d 00 10 00 00       	sub    $0x1000,%eax
80108ce9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108cec:	eb 4a                	jmp    80108d38 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cf1:	8b 00                	mov    (%eax),%eax
80108cf3:	83 e0 01             	and    $0x1,%eax
80108cf6:	85 c0                	test   %eax,%eax
80108cf8:	74 3e                	je     80108d38 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cfd:	8b 00                	mov    (%eax),%eax
80108cff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d04:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108d07:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d0b:	75 0c                	jne    80108d19 <deallocuvm+0x8d>
        panic("kfree");
80108d0d:	c7 04 24 5d a1 10 80 	movl   $0x8010a15d,(%esp)
80108d14:	e8 3b 78 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108d19:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d1c:	05 00 00 00 80       	add    $0x80000000,%eax
80108d21:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108d24:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d27:	89 04 24             	mov    %eax,(%esp)
80108d2a:	e8 80 a0 ff ff       	call   80102daf <kfree>
      *pte = 0;
80108d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d32:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108d38:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d42:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d45:	0f 82 6c ff ff ff    	jb     80108cb7 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108d4b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108d4e:	c9                   	leave  
80108d4f:	c3                   	ret    

80108d50 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108d50:	55                   	push   %ebp
80108d51:	89 e5                	mov    %esp,%ebp
80108d53:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108d56:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108d5a:	75 0c                	jne    80108d68 <freevm+0x18>
    panic("freevm: no pgdir");
80108d5c:	c7 04 24 63 a1 10 80 	movl   $0x8010a163,(%esp)
80108d63:	e8 ec 77 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108d68:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d6f:	00 
80108d70:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108d77:	80 
80108d78:	8b 45 08             	mov    0x8(%ebp),%eax
80108d7b:	89 04 24             	mov    %eax,(%esp)
80108d7e:	e8 09 ff ff ff       	call   80108c8c <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108d83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d8a:	eb 44                	jmp    80108dd0 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d8f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108d96:	8b 45 08             	mov    0x8(%ebp),%eax
80108d99:	01 d0                	add    %edx,%eax
80108d9b:	8b 00                	mov    (%eax),%eax
80108d9d:	83 e0 01             	and    $0x1,%eax
80108da0:	85 c0                	test   %eax,%eax
80108da2:	74 29                	je     80108dcd <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108da7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108dae:	8b 45 08             	mov    0x8(%ebp),%eax
80108db1:	01 d0                	add    %edx,%eax
80108db3:	8b 00                	mov    (%eax),%eax
80108db5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dba:	05 00 00 00 80       	add    $0x80000000,%eax
80108dbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108dc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dc5:	89 04 24             	mov    %eax,(%esp)
80108dc8:	e8 e2 9f ff ff       	call   80102daf <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108dcd:	ff 45 f4             	incl   -0xc(%ebp)
80108dd0:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108dd7:	76 b3                	jbe    80108d8c <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108dd9:	8b 45 08             	mov    0x8(%ebp),%eax
80108ddc:	89 04 24             	mov    %eax,(%esp)
80108ddf:	e8 cb 9f ff ff       	call   80102daf <kfree>
}
80108de4:	c9                   	leave  
80108de5:	c3                   	ret    

80108de6 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108de6:	55                   	push   %ebp
80108de7:	89 e5                	mov    %esp,%ebp
80108de9:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108dec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108df3:	00 
80108df4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108df7:	89 44 24 04          	mov    %eax,0x4(%esp)
80108dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80108dfe:	89 04 24             	mov    %eax,(%esp)
80108e01:	e8 72 f8 ff ff       	call   80108678 <walkpgdir>
80108e06:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108e09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108e0d:	75 0c                	jne    80108e1b <clearpteu+0x35>
    panic("clearpteu");
80108e0f:	c7 04 24 74 a1 10 80 	movl   $0x8010a174,(%esp)
80108e16:	e8 39 77 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e1e:	8b 00                	mov    (%eax),%eax
80108e20:	83 e0 fb             	and    $0xfffffffb,%eax
80108e23:	89 c2                	mov    %eax,%edx
80108e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e28:	89 10                	mov    %edx,(%eax)
}
80108e2a:	c9                   	leave  
80108e2b:	c3                   	ret    

80108e2c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108e2c:	55                   	push   %ebp
80108e2d:	89 e5                	mov    %esp,%ebp
80108e2f:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108e32:	e8 73 f9 ff ff       	call   801087aa <setupkvm>
80108e37:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108e3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108e3e:	75 0a                	jne    80108e4a <copyuvm+0x1e>
    return 0;
80108e40:	b8 00 00 00 00       	mov    $0x0,%eax
80108e45:	e9 f8 00 00 00       	jmp    80108f42 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108e4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e51:	e9 cb 00 00 00       	jmp    80108f21 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108e56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e60:	00 
80108e61:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e65:	8b 45 08             	mov    0x8(%ebp),%eax
80108e68:	89 04 24             	mov    %eax,(%esp)
80108e6b:	e8 08 f8 ff ff       	call   80108678 <walkpgdir>
80108e70:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108e73:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108e77:	75 0c                	jne    80108e85 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108e79:	c7 04 24 7e a1 10 80 	movl   $0x8010a17e,(%esp)
80108e80:	e8 cf 76 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108e85:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e88:	8b 00                	mov    (%eax),%eax
80108e8a:	83 e0 01             	and    $0x1,%eax
80108e8d:	85 c0                	test   %eax,%eax
80108e8f:	75 0c                	jne    80108e9d <copyuvm+0x71>
      panic("copyuvm: page not present");
80108e91:	c7 04 24 98 a1 10 80 	movl   $0x8010a198,(%esp)
80108e98:	e8 b7 76 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108e9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ea0:	8b 00                	mov    (%eax),%eax
80108ea2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ea7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108eaa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ead:	8b 00                	mov    (%eax),%eax
80108eaf:	25 ff 0f 00 00       	and    $0xfff,%eax
80108eb4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108eb7:	e8 d0 9f ff ff       	call   80102e8c <kalloc>
80108ebc:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108ebf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108ec3:	75 02                	jne    80108ec7 <copyuvm+0x9b>
      goto bad;
80108ec5:	eb 6b                	jmp    80108f32 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108eca:	05 00 00 00 80       	add    $0x80000000,%eax
80108ecf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ed6:	00 
80108ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
80108edb:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ede:	89 04 24             	mov    %eax,(%esp)
80108ee1:	e8 e5 c8 ff ff       	call   801057cb <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108ee6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108ee9:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108eec:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ef5:	89 54 24 10          	mov    %edx,0x10(%esp)
80108ef9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108efd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108f04:	00 
80108f05:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f0c:	89 04 24             	mov    %eax,(%esp)
80108f0f:	e8 00 f8 ff ff       	call   80108714 <mappages>
80108f14:	85 c0                	test   %eax,%eax
80108f16:	79 02                	jns    80108f1a <copyuvm+0xee>
      goto bad;
80108f18:	eb 18                	jmp    80108f32 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108f1a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f24:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f27:	0f 82 29 ff ff ff    	jb     80108e56 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f30:	eb 10                	jmp    80108f42 <copyuvm+0x116>

bad:
  freevm(d);
80108f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f35:	89 04 24             	mov    %eax,(%esp)
80108f38:	e8 13 fe ff ff       	call   80108d50 <freevm>
  return 0;
80108f3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f42:	c9                   	leave  
80108f43:	c3                   	ret    

80108f44 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108f44:	55                   	push   %ebp
80108f45:	89 e5                	mov    %esp,%ebp
80108f47:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108f4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f51:	00 
80108f52:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f55:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f59:	8b 45 08             	mov    0x8(%ebp),%eax
80108f5c:	89 04 24             	mov    %eax,(%esp)
80108f5f:	e8 14 f7 ff ff       	call   80108678 <walkpgdir>
80108f64:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108f67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f6a:	8b 00                	mov    (%eax),%eax
80108f6c:	83 e0 01             	and    $0x1,%eax
80108f6f:	85 c0                	test   %eax,%eax
80108f71:	75 07                	jne    80108f7a <uva2ka+0x36>
    return 0;
80108f73:	b8 00 00 00 00       	mov    $0x0,%eax
80108f78:	eb 22                	jmp    80108f9c <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108f7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f7d:	8b 00                	mov    (%eax),%eax
80108f7f:	83 e0 04             	and    $0x4,%eax
80108f82:	85 c0                	test   %eax,%eax
80108f84:	75 07                	jne    80108f8d <uva2ka+0x49>
    return 0;
80108f86:	b8 00 00 00 00       	mov    $0x0,%eax
80108f8b:	eb 0f                	jmp    80108f9c <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f90:	8b 00                	mov    (%eax),%eax
80108f92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f97:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108f9c:	c9                   	leave  
80108f9d:	c3                   	ret    

80108f9e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108f9e:	55                   	push   %ebp
80108f9f:	89 e5                	mov    %esp,%ebp
80108fa1:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108fa4:	8b 45 10             	mov    0x10(%ebp),%eax
80108fa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108faa:	e9 87 00 00 00       	jmp    80109036 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108faf:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fb2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fb7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108fba:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fc1:	8b 45 08             	mov    0x8(%ebp),%eax
80108fc4:	89 04 24             	mov    %eax,(%esp)
80108fc7:	e8 78 ff ff ff       	call   80108f44 <uva2ka>
80108fcc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108fcf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108fd3:	75 07                	jne    80108fdc <copyout+0x3e>
      return -1;
80108fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108fda:	eb 69                	jmp    80109045 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fdf:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108fe2:	29 c2                	sub    %eax,%edx
80108fe4:	89 d0                	mov    %edx,%eax
80108fe6:	05 00 10 00 00       	add    $0x1000,%eax
80108feb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ff1:	3b 45 14             	cmp    0x14(%ebp),%eax
80108ff4:	76 06                	jbe    80108ffc <copyout+0x5e>
      n = len;
80108ff6:	8b 45 14             	mov    0x14(%ebp),%eax
80108ff9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108ffc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fff:	8b 55 0c             	mov    0xc(%ebp),%edx
80109002:	29 c2                	sub    %eax,%edx
80109004:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109007:	01 c2                	add    %eax,%edx
80109009:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010900c:	89 44 24 08          	mov    %eax,0x8(%esp)
80109010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109013:	89 44 24 04          	mov    %eax,0x4(%esp)
80109017:	89 14 24             	mov    %edx,(%esp)
8010901a:	e8 ac c7 ff ff       	call   801057cb <memmove>
    len -= n;
8010901f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109022:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109025:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109028:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010902b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010902e:	05 00 10 00 00       	add    $0x1000,%eax
80109033:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109036:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010903a:	0f 85 6f ff ff ff    	jne    80108faf <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109040:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109045:	c9                   	leave  
80109046:	c3                   	ret    
	...

80109048 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80109048:	55                   	push   %ebp
80109049:	89 e5                	mov    %esp,%ebp
8010904b:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
8010904e:	8b 45 10             	mov    0x10(%ebp),%eax
80109051:	89 44 24 08          	mov    %eax,0x8(%esp)
80109055:	8b 45 0c             	mov    0xc(%ebp),%eax
80109058:	89 44 24 04          	mov    %eax,0x4(%esp)
8010905c:	8b 45 08             	mov    0x8(%ebp),%eax
8010905f:	89 04 24             	mov    %eax,(%esp)
80109062:	e8 64 c7 ff ff       	call   801057cb <memmove>
}
80109067:	c9                   	leave  
80109068:	c3                   	ret    

80109069 <strcpy>:

char* strcpy(char *s, char *t){
80109069:	55                   	push   %ebp
8010906a:	89 e5                	mov    %esp,%ebp
8010906c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010906f:	8b 45 08             	mov    0x8(%ebp),%eax
80109072:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80109075:	90                   	nop
80109076:	8b 45 08             	mov    0x8(%ebp),%eax
80109079:	8d 50 01             	lea    0x1(%eax),%edx
8010907c:	89 55 08             	mov    %edx,0x8(%ebp)
8010907f:	8b 55 0c             	mov    0xc(%ebp),%edx
80109082:	8d 4a 01             	lea    0x1(%edx),%ecx
80109085:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80109088:	8a 12                	mov    (%edx),%dl
8010908a:	88 10                	mov    %dl,(%eax)
8010908c:	8a 00                	mov    (%eax),%al
8010908e:	84 c0                	test   %al,%al
80109090:	75 e4                	jne    80109076 <strcpy+0xd>
    ;
  return os;
80109092:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109095:	c9                   	leave  
80109096:	c3                   	ret    

80109097 <strcmp>:

int
strcmp(const char *p, const char *q)
{
80109097:	55                   	push   %ebp
80109098:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
8010909a:	eb 06                	jmp    801090a2 <strcmp+0xb>
    p++, q++;
8010909c:	ff 45 08             	incl   0x8(%ebp)
8010909f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
801090a2:	8b 45 08             	mov    0x8(%ebp),%eax
801090a5:	8a 00                	mov    (%eax),%al
801090a7:	84 c0                	test   %al,%al
801090a9:	74 0e                	je     801090b9 <strcmp+0x22>
801090ab:	8b 45 08             	mov    0x8(%ebp),%eax
801090ae:	8a 10                	mov    (%eax),%dl
801090b0:	8b 45 0c             	mov    0xc(%ebp),%eax
801090b3:	8a 00                	mov    (%eax),%al
801090b5:	38 c2                	cmp    %al,%dl
801090b7:	74 e3                	je     8010909c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801090b9:	8b 45 08             	mov    0x8(%ebp),%eax
801090bc:	8a 00                	mov    (%eax),%al
801090be:	0f b6 d0             	movzbl %al,%edx
801090c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801090c4:	8a 00                	mov    (%eax),%al
801090c6:	0f b6 c0             	movzbl %al,%eax
801090c9:	29 c2                	sub    %eax,%edx
801090cb:	89 d0                	mov    %edx,%eax
}
801090cd:	5d                   	pop    %ebp
801090ce:	c3                   	ret    

801090cf <set_root_inode>:

// struct con

void set_root_inode(char* name){
801090cf:	55                   	push   %ebp
801090d0:	89 e5                	mov    %esp,%ebp
801090d2:	53                   	push   %ebx
801090d3:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
801090d6:	8b 45 08             	mov    0x8(%ebp),%eax
801090d9:	89 04 24             	mov    %eax,(%esp)
801090dc:	e8 02 01 00 00       	call   801091e3 <find>
801090e1:	89 c3                	mov    %eax,%ebx
801090e3:	8b 45 08             	mov    0x8(%ebp),%eax
801090e6:	89 04 24             	mov    %eax,(%esp)
801090e9:	e8 3f 96 ff ff       	call   8010272d <namei>
801090ee:	89 c2                	mov    %eax,%edx
801090f0:	89 d8                	mov    %ebx,%eax
801090f2:	01 c0                	add    %eax,%eax
801090f4:	01 d8                	add    %ebx,%eax
801090f6:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
801090fd:	01 c8                	add    %ecx,%eax
801090ff:	c1 e0 02             	shl    $0x2,%eax
80109102:	05 30 8c 11 80       	add    $0x80118c30,%eax
80109107:	89 50 08             	mov    %edx,0x8(%eax)

}
8010910a:	83 c4 14             	add    $0x14,%esp
8010910d:	5b                   	pop    %ebx
8010910e:	5d                   	pop    %ebp
8010910f:	c3                   	ret    

80109110 <get_name>:

void get_name(int vc_num, char* name){
80109110:	55                   	push   %ebp
80109111:	89 e5                	mov    %esp,%ebp
80109113:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
80109116:	8b 55 08             	mov    0x8(%ebp),%edx
80109119:	89 d0                	mov    %edx,%eax
8010911b:	01 c0                	add    %eax,%eax
8010911d:	01 d0                	add    %edx,%eax
8010911f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109126:	01 d0                	add    %edx,%eax
80109128:	c1 e0 02             	shl    $0x2,%eax
8010912b:	83 c0 10             	add    $0x10,%eax
8010912e:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109133:	83 c0 08             	add    $0x8,%eax
80109136:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
80109139:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
80109140:	eb 03                	jmp    80109145 <get_name+0x35>
	{
		i++;
80109142:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
80109145:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109148:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010914b:	01 d0                	add    %edx,%eax
8010914d:	8a 00                	mov    (%eax),%al
8010914f:	84 c0                	test   %al,%al
80109151:	75 ef                	jne    80109142 <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
80109153:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109156:	89 44 24 08          	mov    %eax,0x8(%esp)
8010915a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010915d:	89 44 24 04          	mov    %eax,0x4(%esp)
80109161:	8b 45 0c             	mov    0xc(%ebp),%eax
80109164:	89 04 24             	mov    %eax,(%esp)
80109167:	e8 dc fe ff ff       	call   80109048 <memcpy2>
}
8010916c:	c9                   	leave  
8010916d:	c3                   	ret    

8010916e <g_name>:

char* g_name(int vc_bun){
8010916e:	55                   	push   %ebp
8010916f:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
80109171:	8b 55 08             	mov    0x8(%ebp),%edx
80109174:	89 d0                	mov    %edx,%eax
80109176:	01 c0                	add    %eax,%eax
80109178:	01 d0                	add    %edx,%eax
8010917a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109181:	01 d0                	add    %edx,%eax
80109183:	c1 e0 02             	shl    $0x2,%eax
80109186:	83 c0 10             	add    $0x10,%eax
80109189:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010918e:	83 c0 08             	add    $0x8,%eax
}
80109191:	5d                   	pop    %ebp
80109192:	c3                   	ret    

80109193 <is_full>:

int is_full(){
80109193:	55                   	push   %ebp
80109194:	89 e5                	mov    %esp,%ebp
80109196:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109199:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091a0:	eb 34                	jmp    801091d6 <is_full+0x43>
		if(strlen(containers[i].name) == 0){
801091a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091a5:	89 d0                	mov    %edx,%eax
801091a7:	01 c0                	add    %eax,%eax
801091a9:	01 d0                	add    %edx,%eax
801091ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801091b2:	01 d0                	add    %edx,%eax
801091b4:	c1 e0 02             	shl    $0x2,%eax
801091b7:	83 c0 10             	add    $0x10,%eax
801091ba:	05 00 8c 11 80       	add    $0x80118c00,%eax
801091bf:	83 c0 08             	add    $0x8,%eax
801091c2:	89 04 24             	mov    %eax,(%esp)
801091c5:	e8 8b c7 ff ff       	call   80105955 <strlen>
801091ca:	85 c0                	test   %eax,%eax
801091cc:	75 05                	jne    801091d3 <is_full+0x40>
			return i;
801091ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091d1:	eb 0e                	jmp    801091e1 <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801091d3:	ff 45 f4             	incl   -0xc(%ebp)
801091d6:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801091da:	7e c6                	jle    801091a2 <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
801091dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801091e1:	c9                   	leave  
801091e2:	c3                   	ret    

801091e3 <find>:

int find(char* name){
801091e3:	55                   	push   %ebp
801091e4:	89 e5                	mov    %esp,%ebp
801091e6:	83 ec 18             	sub    $0x18,%esp
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
801091e9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801091f0:	eb 54                	jmp    80109246 <find+0x63>
		if(strcmp(name, "") == 0){
801091f2:	c7 44 24 04 b4 a1 10 	movl   $0x8010a1b4,0x4(%esp)
801091f9:	80 
801091fa:	8b 45 08             	mov    0x8(%ebp),%eax
801091fd:	89 04 24             	mov    %eax,(%esp)
80109200:	e8 92 fe ff ff       	call   80109097 <strcmp>
80109205:	85 c0                	test   %eax,%eax
80109207:	75 02                	jne    8010920b <find+0x28>
			continue;
80109209:	eb 38                	jmp    80109243 <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
8010920b:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010920e:	89 d0                	mov    %edx,%eax
80109210:	01 c0                	add    %eax,%eax
80109212:	01 d0                	add    %edx,%eax
80109214:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010921b:	01 d0                	add    %edx,%eax
8010921d:	c1 e0 02             	shl    $0x2,%eax
80109220:	83 c0 10             	add    $0x10,%eax
80109223:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109228:	83 c0 08             	add    $0x8,%eax
8010922b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010922f:	8b 45 08             	mov    0x8(%ebp),%eax
80109232:	89 04 24             	mov    %eax,(%esp)
80109235:	e8 5d fe ff ff       	call   80109097 <strcmp>
8010923a:	85 c0                	test   %eax,%eax
8010923c:	75 05                	jne    80109243 <find+0x60>
			return i;
8010923e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109241:	eb 0e                	jmp    80109251 <find+0x6e>
}

int find(char* name){
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80109243:	ff 45 fc             	incl   -0x4(%ebp)
80109246:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
8010924a:	7e a6                	jle    801091f2 <find+0xf>
		}
		if(strcmp(name, containers[i].name) == 0){
			return i;
		}
	}
	return -1;
8010924c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80109251:	c9                   	leave  
80109252:	c3                   	ret    

80109253 <get_max_proc>:

int get_max_proc(int vc_num){
80109253:	55                   	push   %ebp
80109254:	89 e5                	mov    %esp,%ebp
80109256:	57                   	push   %edi
80109257:	56                   	push   %esi
80109258:	53                   	push   %ebx
80109259:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
8010925c:	8b 55 08             	mov    0x8(%ebp),%edx
8010925f:	89 d0                	mov    %edx,%eax
80109261:	01 c0                	add    %eax,%eax
80109263:	01 d0                	add    %edx,%eax
80109265:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010926c:	01 d0                	add    %edx,%eax
8010926e:	c1 e0 02             	shl    $0x2,%eax
80109271:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109276:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109279:	89 c3                	mov    %eax,%ebx
8010927b:	b8 0f 00 00 00       	mov    $0xf,%eax
80109280:	89 d7                	mov    %edx,%edi
80109282:	89 de                	mov    %ebx,%esi
80109284:	89 c1                	mov    %eax,%ecx
80109286:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
80109288:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
8010928b:	83 c4 40             	add    $0x40,%esp
8010928e:	5b                   	pop    %ebx
8010928f:	5e                   	pop    %esi
80109290:	5f                   	pop    %edi
80109291:	5d                   	pop    %ebp
80109292:	c3                   	ret    

80109293 <get_container>:

struct container* get_container(int vc_num){
80109293:	55                   	push   %ebp
80109294:	89 e5                	mov    %esp,%ebp
80109296:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
80109299:	8b 55 08             	mov    0x8(%ebp),%edx
8010929c:	89 d0                	mov    %edx,%eax
8010929e:	01 c0                	add    %eax,%eax
801092a0:	01 d0                	add    %edx,%eax
801092a2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092a9:	01 d0                	add    %edx,%eax
801092ab:	c1 e0 02             	shl    $0x2,%eax
801092ae:	05 00 8c 11 80       	add    $0x80118c00,%eax
801092b3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return cont;
801092b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801092b9:	c9                   	leave  
801092ba:	c3                   	ret    

801092bb <get_max_mem>:

int get_max_mem(int vc_num){
801092bb:	55                   	push   %ebp
801092bc:	89 e5                	mov    %esp,%ebp
801092be:	57                   	push   %edi
801092bf:	56                   	push   %esi
801092c0:	53                   	push   %ebx
801092c1:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801092c4:	8b 55 08             	mov    0x8(%ebp),%edx
801092c7:	89 d0                	mov    %edx,%eax
801092c9:	01 c0                	add    %eax,%eax
801092cb:	01 d0                	add    %edx,%eax
801092cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092d4:	01 d0                	add    %edx,%eax
801092d6:	c1 e0 02             	shl    $0x2,%eax
801092d9:	05 00 8c 11 80       	add    $0x80118c00,%eax
801092de:	8d 55 b8             	lea    -0x48(%ebp),%edx
801092e1:	89 c3                	mov    %eax,%ebx
801092e3:	b8 0f 00 00 00       	mov    $0xf,%eax
801092e8:	89 d7                	mov    %edx,%edi
801092ea:	89 de                	mov    %ebx,%esi
801092ec:	89 c1                	mov    %eax,%ecx
801092ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
801092f0:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
801092f3:	83 c4 40             	add    $0x40,%esp
801092f6:	5b                   	pop    %ebx
801092f7:	5e                   	pop    %esi
801092f8:	5f                   	pop    %edi
801092f9:	5d                   	pop    %ebp
801092fa:	c3                   	ret    

801092fb <get_max_disk>:

int get_max_disk(int vc_num){
801092fb:	55                   	push   %ebp
801092fc:	89 e5                	mov    %esp,%ebp
801092fe:	57                   	push   %edi
801092ff:	56                   	push   %esi
80109300:	53                   	push   %ebx
80109301:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80109304:	8b 55 08             	mov    0x8(%ebp),%edx
80109307:	89 d0                	mov    %edx,%eax
80109309:	01 c0                	add    %eax,%eax
8010930b:	01 d0                	add    %edx,%eax
8010930d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109314:	01 d0                	add    %edx,%eax
80109316:	c1 e0 02             	shl    $0x2,%eax
80109319:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010931e:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109321:	89 c3                	mov    %eax,%ebx
80109323:	b8 0f 00 00 00       	mov    $0xf,%eax
80109328:	89 d7                	mov    %edx,%edi
8010932a:	89 de                	mov    %ebx,%esi
8010932c:	89 c1                	mov    %eax,%ecx
8010932e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80109330:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
80109333:	83 c4 40             	add    $0x40,%esp
80109336:	5b                   	pop    %ebx
80109337:	5e                   	pop    %esi
80109338:	5f                   	pop    %edi
80109339:	5d                   	pop    %ebp
8010933a:	c3                   	ret    

8010933b <get_curr_proc>:

int get_curr_proc(int vc_num){
8010933b:	55                   	push   %ebp
8010933c:	89 e5                	mov    %esp,%ebp
8010933e:	57                   	push   %edi
8010933f:	56                   	push   %esi
80109340:	53                   	push   %ebx
80109341:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80109344:	8b 55 08             	mov    0x8(%ebp),%edx
80109347:	89 d0                	mov    %edx,%eax
80109349:	01 c0                	add    %eax,%eax
8010934b:	01 d0                	add    %edx,%eax
8010934d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109354:	01 d0                	add    %edx,%eax
80109356:	c1 e0 02             	shl    $0x2,%eax
80109359:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010935e:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109361:	89 c3                	mov    %eax,%ebx
80109363:	b8 0f 00 00 00       	mov    $0xf,%eax
80109368:	89 d7                	mov    %edx,%edi
8010936a:	89 de                	mov    %ebx,%esi
8010936c:	89 c1                	mov    %eax,%ecx
8010936e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
80109370:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
80109373:	83 c4 40             	add    $0x40,%esp
80109376:	5b                   	pop    %ebx
80109377:	5e                   	pop    %esi
80109378:	5f                   	pop    %edi
80109379:	5d                   	pop    %ebp
8010937a:	c3                   	ret    

8010937b <get_curr_mem>:

int get_curr_mem(int vc_num){
8010937b:	55                   	push   %ebp
8010937c:	89 e5                	mov    %esp,%ebp
8010937e:	57                   	push   %edi
8010937f:	56                   	push   %esi
80109380:	53                   	push   %ebx
80109381:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80109384:	8b 55 08             	mov    0x8(%ebp),%edx
80109387:	89 d0                	mov    %edx,%eax
80109389:	01 c0                	add    %eax,%eax
8010938b:	01 d0                	add    %edx,%eax
8010938d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109394:	01 d0                	add    %edx,%eax
80109396:	c1 e0 02             	shl    $0x2,%eax
80109399:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010939e:	8d 55 b8             	lea    -0x48(%ebp),%edx
801093a1:	89 c3                	mov    %eax,%ebx
801093a3:	b8 0f 00 00 00       	mov    $0xf,%eax
801093a8:	89 d7                	mov    %edx,%edi
801093aa:	89 de                	mov    %ebx,%esi
801093ac:	89 c1                	mov    %eax,%ecx
801093ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
	return x.curr_mem; 
801093b0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
801093b3:	83 c4 40             	add    $0x40,%esp
801093b6:	5b                   	pop    %ebx
801093b7:	5e                   	pop    %esi
801093b8:	5f                   	pop    %edi
801093b9:	5d                   	pop    %ebp
801093ba:	c3                   	ret    

801093bb <get_curr_disk>:

int get_curr_disk(int vc_num){
801093bb:	55                   	push   %ebp
801093bc:	89 e5                	mov    %esp,%ebp
801093be:	57                   	push   %edi
801093bf:	56                   	push   %esi
801093c0:	53                   	push   %ebx
801093c1:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801093c4:	8b 55 08             	mov    0x8(%ebp),%edx
801093c7:	89 d0                	mov    %edx,%eax
801093c9:	01 c0                	add    %eax,%eax
801093cb:	01 d0                	add    %edx,%eax
801093cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093d4:	01 d0                	add    %edx,%eax
801093d6:	c1 e0 02             	shl    $0x2,%eax
801093d9:	05 00 8c 11 80       	add    $0x80118c00,%eax
801093de:	8d 55 b8             	lea    -0x48(%ebp),%edx
801093e1:	89 c3                	mov    %eax,%ebx
801093e3:	b8 0f 00 00 00       	mov    $0xf,%eax
801093e8:	89 d7                	mov    %edx,%edi
801093ea:	89 de                	mov    %ebx,%esi
801093ec:	89 c1                	mov    %eax,%ecx
801093ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
801093f0:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
801093f3:	83 c4 40             	add    $0x40,%esp
801093f6:	5b                   	pop    %ebx
801093f7:	5e                   	pop    %esi
801093f8:	5f                   	pop    %edi
801093f9:	5d                   	pop    %ebp
801093fa:	c3                   	ret    

801093fb <set_name>:

void set_name(char* name, int vc_num){
801093fb:	55                   	push   %ebp
801093fc:	89 e5                	mov    %esp,%ebp
801093fe:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80109401:	8b 55 0c             	mov    0xc(%ebp),%edx
80109404:	89 d0                	mov    %edx,%eax
80109406:	01 c0                	add    %eax,%eax
80109408:	01 d0                	add    %edx,%eax
8010940a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109411:	01 d0                	add    %edx,%eax
80109413:	c1 e0 02             	shl    $0x2,%eax
80109416:	83 c0 10             	add    $0x10,%eax
80109419:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010941e:	8d 50 08             	lea    0x8(%eax),%edx
80109421:	8b 45 08             	mov    0x8(%ebp),%eax
80109424:	89 44 24 04          	mov    %eax,0x4(%esp)
80109428:	89 14 24             	mov    %edx,(%esp)
8010942b:	e8 39 fc ff ff       	call   80109069 <strcpy>
}
80109430:	c9                   	leave  
80109431:	c3                   	ret    

80109432 <set_max_mem>:

void set_max_mem(int mem, int vc_num){
80109432:	55                   	push   %ebp
80109433:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
80109435:	8b 55 0c             	mov    0xc(%ebp),%edx
80109438:	89 d0                	mov    %edx,%eax
8010943a:	01 c0                	add    %eax,%eax
8010943c:	01 d0                	add    %edx,%eax
8010943e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109445:	01 d0                	add    %edx,%eax
80109447:	c1 e0 02             	shl    $0x2,%eax
8010944a:	8d 90 00 8c 11 80    	lea    -0x7fee7400(%eax),%edx
80109450:	8b 45 08             	mov    0x8(%ebp),%eax
80109453:	89 02                	mov    %eax,(%edx)
}
80109455:	5d                   	pop    %ebp
80109456:	c3                   	ret    

80109457 <set_max_disk>:

void set_max_disk(int disk, int vc_num){
80109457:	55                   	push   %ebp
80109458:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
8010945a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010945d:	89 d0                	mov    %edx,%eax
8010945f:	01 c0                	add    %eax,%eax
80109461:	01 d0                	add    %edx,%eax
80109463:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010946a:	01 d0                	add    %edx,%eax
8010946c:	c1 e0 02             	shl    $0x2,%eax
8010946f:	8d 90 00 8c 11 80    	lea    -0x7fee7400(%eax),%edx
80109475:	8b 45 08             	mov    0x8(%ebp),%eax
80109478:	89 42 08             	mov    %eax,0x8(%edx)
}
8010947b:	5d                   	pop    %ebp
8010947c:	c3                   	ret    

8010947d <set_max_proc>:

void set_max_proc(int procs, int vc_num){
8010947d:	55                   	push   %ebp
8010947e:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
80109480:	8b 55 0c             	mov    0xc(%ebp),%edx
80109483:	89 d0                	mov    %edx,%eax
80109485:	01 c0                	add    %eax,%eax
80109487:	01 d0                	add    %edx,%eax
80109489:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109490:	01 d0                	add    %edx,%eax
80109492:	c1 e0 02             	shl    $0x2,%eax
80109495:	8d 90 00 8c 11 80    	lea    -0x7fee7400(%eax),%edx
8010949b:	8b 45 08             	mov    0x8(%ebp),%eax
8010949e:	89 42 04             	mov    %eax,0x4(%edx)
}
801094a1:	5d                   	pop    %ebp
801094a2:	c3                   	ret    

801094a3 <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
801094a3:	55                   	push   %ebp
801094a4:	89 e5                	mov    %esp,%ebp
801094a6:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_mem + 1) > containers[vc_num].max_mem){
801094a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801094ac:	89 d0                	mov    %edx,%eax
801094ae:	01 c0                	add    %eax,%eax
801094b0:	01 d0                	add    %edx,%eax
801094b2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094b9:	01 d0                	add    %edx,%eax
801094bb:	c1 e0 02             	shl    $0x2,%eax
801094be:	05 00 8c 11 80       	add    $0x80118c00,%eax
801094c3:	8b 40 0c             	mov    0xc(%eax),%eax
801094c6:	8d 48 01             	lea    0x1(%eax),%ecx
801094c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801094cc:	89 d0                	mov    %edx,%eax
801094ce:	01 c0                	add    %eax,%eax
801094d0:	01 d0                	add    %edx,%eax
801094d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094d9:	01 d0                	add    %edx,%eax
801094db:	c1 e0 02             	shl    $0x2,%eax
801094de:	05 00 8c 11 80       	add    $0x80118c00,%eax
801094e3:	8b 00                	mov    (%eax),%eax
801094e5:	39 c1                	cmp    %eax,%ecx
801094e7:	7e 0e                	jle    801094f7 <set_curr_mem+0x54>
		cprintf("Exceded memory resource; killing container");
801094e9:	c7 04 24 b8 a1 10 80 	movl   $0x8010a1b8,(%esp)
801094f0:	e8 cc 6e ff ff       	call   801003c1 <cprintf>
801094f5:	eb 3d                	jmp    80109534 <set_curr_mem+0x91>
	}
	else{
		containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
801094f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801094fa:	89 d0                	mov    %edx,%eax
801094fc:	01 c0                	add    %eax,%eax
801094fe:	01 d0                	add    %edx,%eax
80109500:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109507:	01 d0                	add    %edx,%eax
80109509:	c1 e0 02             	shl    $0x2,%eax
8010950c:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109511:	8b 40 0c             	mov    0xc(%eax),%eax
80109514:	8d 48 01             	lea    0x1(%eax),%ecx
80109517:	8b 55 0c             	mov    0xc(%ebp),%edx
8010951a:	89 d0                	mov    %edx,%eax
8010951c:	01 c0                	add    %eax,%eax
8010951e:	01 d0                	add    %edx,%eax
80109520:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109527:	01 d0                	add    %edx,%eax
80109529:	c1 e0 02             	shl    $0x2,%eax
8010952c:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109531:	89 48 0c             	mov    %ecx,0xc(%eax)
	}
}
80109534:	c9                   	leave  
80109535:	c3                   	ret    

80109536 <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
80109536:	55                   	push   %ebp
80109537:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;	
80109539:	8b 55 0c             	mov    0xc(%ebp),%edx
8010953c:	89 d0                	mov    %edx,%eax
8010953e:	01 c0                	add    %eax,%eax
80109540:	01 d0                	add    %edx,%eax
80109542:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109549:	01 d0                	add    %edx,%eax
8010954b:	c1 e0 02             	shl    $0x2,%eax
8010954e:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109553:	8b 40 0c             	mov    0xc(%eax),%eax
80109556:	8d 48 ff             	lea    -0x1(%eax),%ecx
80109559:	8b 55 0c             	mov    0xc(%ebp),%edx
8010955c:	89 d0                	mov    %edx,%eax
8010955e:	01 c0                	add    %eax,%eax
80109560:	01 d0                	add    %edx,%eax
80109562:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109569:	01 d0                	add    %edx,%eax
8010956b:	c1 e0 02             	shl    $0x2,%eax
8010956e:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109573:	89 48 0c             	mov    %ecx,0xc(%eax)
}
80109576:	5d                   	pop    %ebp
80109577:	c3                   	ret    

80109578 <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
80109578:	55                   	push   %ebp
80109579:	89 e5                	mov    %esp,%ebp
8010957b:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_disk + disk)/1024 > containers[vc_num].max_disk){
8010957e:	8b 55 0c             	mov    0xc(%ebp),%edx
80109581:	89 d0                	mov    %edx,%eax
80109583:	01 c0                	add    %eax,%eax
80109585:	01 d0                	add    %edx,%eax
80109587:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010958e:	01 d0                	add    %edx,%eax
80109590:	c1 e0 02             	shl    $0x2,%eax
80109593:	05 10 8c 11 80       	add    $0x80118c10,%eax
80109598:	8b 50 04             	mov    0x4(%eax),%edx
8010959b:	8b 45 08             	mov    0x8(%ebp),%eax
8010959e:	01 d0                	add    %edx,%eax
801095a0:	85 c0                	test   %eax,%eax
801095a2:	79 05                	jns    801095a9 <set_curr_disk+0x31>
801095a4:	05 ff 03 00 00       	add    $0x3ff,%eax
801095a9:	c1 f8 0a             	sar    $0xa,%eax
801095ac:	89 c1                	mov    %eax,%ecx
801095ae:	8b 55 0c             	mov    0xc(%ebp),%edx
801095b1:	89 d0                	mov    %edx,%eax
801095b3:	01 c0                	add    %eax,%eax
801095b5:	01 d0                	add    %edx,%eax
801095b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095be:	01 d0                	add    %edx,%eax
801095c0:	c1 e0 02             	shl    $0x2,%eax
801095c3:	05 00 8c 11 80       	add    $0x80118c00,%eax
801095c8:	8b 40 08             	mov    0x8(%eax),%eax
801095cb:	39 c1                	cmp    %eax,%ecx
801095cd:	7e 0e                	jle    801095dd <set_curr_disk+0x65>
		cprintf("Exceded disk resource; killing container");
801095cf:	c7 04 24 e4 a1 10 80 	movl   $0x8010a1e4,(%esp)
801095d6:	e8 e6 6d ff ff       	call   801003c1 <cprintf>
801095db:	eb 40                	jmp    8010961d <set_curr_disk+0xa5>
	}
	else{
		containers[vc_num].curr_disk += disk;
801095dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801095e0:	89 d0                	mov    %edx,%eax
801095e2:	01 c0                	add    %eax,%eax
801095e4:	01 d0                	add    %edx,%eax
801095e6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095ed:	01 d0                	add    %edx,%eax
801095ef:	c1 e0 02             	shl    $0x2,%eax
801095f2:	05 10 8c 11 80       	add    $0x80118c10,%eax
801095f7:	8b 50 04             	mov    0x4(%eax),%edx
801095fa:	8b 45 08             	mov    0x8(%ebp),%eax
801095fd:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109600:	8b 55 0c             	mov    0xc(%ebp),%edx
80109603:	89 d0                	mov    %edx,%eax
80109605:	01 c0                	add    %eax,%eax
80109607:	01 d0                	add    %edx,%eax
80109609:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109610:	01 d0                	add    %edx,%eax
80109612:	c1 e0 02             	shl    $0x2,%eax
80109615:	05 10 8c 11 80       	add    $0x80118c10,%eax
8010961a:	89 48 04             	mov    %ecx,0x4(%eax)
	}
}
8010961d:	c9                   	leave  
8010961e:	c3                   	ret    

8010961f <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
8010961f:	55                   	push   %ebp
80109620:	89 e5                	mov    %esp,%ebp
80109622:	83 ec 18             	sub    $0x18,%esp
	if(containers[vc_num].curr_proc + procs > containers[vc_num].max_proc){
80109625:	8b 55 0c             	mov    0xc(%ebp),%edx
80109628:	89 d0                	mov    %edx,%eax
8010962a:	01 c0                	add    %eax,%eax
8010962c:	01 d0                	add    %edx,%eax
8010962e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109635:	01 d0                	add    %edx,%eax
80109637:	c1 e0 02             	shl    $0x2,%eax
8010963a:	05 10 8c 11 80       	add    $0x80118c10,%eax
8010963f:	8b 10                	mov    (%eax),%edx
80109641:	8b 45 08             	mov    0x8(%ebp),%eax
80109644:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109647:	8b 55 0c             	mov    0xc(%ebp),%edx
8010964a:	89 d0                	mov    %edx,%eax
8010964c:	01 c0                	add    %eax,%eax
8010964e:	01 d0                	add    %edx,%eax
80109650:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109657:	01 d0                	add    %edx,%eax
80109659:	c1 e0 02             	shl    $0x2,%eax
8010965c:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109661:	8b 40 04             	mov    0x4(%eax),%eax
80109664:	39 c1                	cmp    %eax,%ecx
80109666:	7e 0e                	jle    80109676 <set_curr_proc+0x57>
		cprintf("Exceded procs resource; killing container");
80109668:	c7 04 24 10 a2 10 80 	movl   $0x8010a210,(%esp)
8010966f:	e8 4d 6d ff ff       	call   801003c1 <cprintf>
80109674:	eb 3e                	jmp    801096b4 <set_curr_proc+0x95>
	}
	else{
		containers[vc_num].curr_proc += procs;
80109676:	8b 55 0c             	mov    0xc(%ebp),%edx
80109679:	89 d0                	mov    %edx,%eax
8010967b:	01 c0                	add    %eax,%eax
8010967d:	01 d0                	add    %edx,%eax
8010967f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109686:	01 d0                	add    %edx,%eax
80109688:	c1 e0 02             	shl    $0x2,%eax
8010968b:	05 10 8c 11 80       	add    $0x80118c10,%eax
80109690:	8b 10                	mov    (%eax),%edx
80109692:	8b 45 08             	mov    0x8(%ebp),%eax
80109695:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109698:	8b 55 0c             	mov    0xc(%ebp),%edx
8010969b:	89 d0                	mov    %edx,%eax
8010969d:	01 c0                	add    %eax,%eax
8010969f:	01 d0                	add    %edx,%eax
801096a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096a8:	01 d0                	add    %edx,%eax
801096aa:	c1 e0 02             	shl    $0x2,%eax
801096ad:	05 10 8c 11 80       	add    $0x80118c10,%eax
801096b2:	89 08                	mov    %ecx,(%eax)
	}
}
801096b4:	c9                   	leave  
801096b5:	c3                   	ret    

801096b6 <max_containers>:

int max_containers(){
801096b6:	55                   	push   %ebp
801096b7:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
801096b9:	b8 04 00 00 00       	mov    $0x4,%eax
}
801096be:	5d                   	pop    %ebp
801096bf:	c3                   	ret    

801096c0 <container_init>:

void container_init(){
801096c0:	55                   	push   %ebp
801096c1:	89 e5                	mov    %esp,%ebp
801096c3:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801096c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801096cd:	e9 f7 00 00 00       	jmp    801097c9 <container_init+0x109>
		strcpy(containers[i].name, "");
801096d2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801096d5:	89 d0                	mov    %edx,%eax
801096d7:	01 c0                	add    %eax,%eax
801096d9:	01 d0                	add    %edx,%eax
801096db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096e2:	01 d0                	add    %edx,%eax
801096e4:	c1 e0 02             	shl    $0x2,%eax
801096e7:	83 c0 10             	add    $0x10,%eax
801096ea:	05 00 8c 11 80       	add    $0x80118c00,%eax
801096ef:	83 c0 08             	add    $0x8,%eax
801096f2:	c7 44 24 04 b4 a1 10 	movl   $0x8010a1b4,0x4(%esp)
801096f9:	80 
801096fa:	89 04 24             	mov    %eax,(%esp)
801096fd:	e8 67 f9 ff ff       	call   80109069 <strcpy>
		containers[i].max_proc = 4;
80109702:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109705:	89 d0                	mov    %edx,%eax
80109707:	01 c0                	add    %eax,%eax
80109709:	01 d0                	add    %edx,%eax
8010970b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109712:	01 d0                	add    %edx,%eax
80109714:	c1 e0 02             	shl    $0x2,%eax
80109717:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010971c:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
		containers[i].max_disk = 100;
80109723:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109726:	89 d0                	mov    %edx,%eax
80109728:	01 c0                	add    %eax,%eax
8010972a:	01 d0                	add    %edx,%eax
8010972c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109733:	01 d0                	add    %edx,%eax
80109735:	c1 e0 02             	shl    $0x2,%eax
80109738:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010973d:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 300;
80109744:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109747:	89 d0                	mov    %edx,%eax
80109749:	01 c0                	add    %eax,%eax
8010974b:	01 d0                	add    %edx,%eax
8010974d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109754:	01 d0                	add    %edx,%eax
80109756:	c1 e0 02             	shl    $0x2,%eax
80109759:	05 00 8c 11 80       	add    $0x80118c00,%eax
8010975e:	c7 00 2c 01 00 00    	movl   $0x12c,(%eax)
		containers[i].curr_proc = 1;
80109764:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109767:	89 d0                	mov    %edx,%eax
80109769:	01 c0                	add    %eax,%eax
8010976b:	01 d0                	add    %edx,%eax
8010976d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109774:	01 d0                	add    %edx,%eax
80109776:	c1 e0 02             	shl    $0x2,%eax
80109779:	05 10 8c 11 80       	add    $0x80118c10,%eax
8010977e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
		containers[i].curr_disk = 0;
80109784:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109787:	89 d0                	mov    %edx,%eax
80109789:	01 c0                	add    %eax,%eax
8010978b:	01 d0                	add    %edx,%eax
8010978d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109794:	01 d0                	add    %edx,%eax
80109796:	c1 e0 02             	shl    $0x2,%eax
80109799:	05 10 8c 11 80       	add    $0x80118c10,%eax
8010979e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
801097a5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801097a8:	89 d0                	mov    %edx,%eax
801097aa:	01 c0                	add    %eax,%eax
801097ac:	01 d0                	add    %edx,%eax
801097ae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097b5:	01 d0                	add    %edx,%eax
801097b7:	c1 e0 02             	shl    $0x2,%eax
801097ba:	05 00 8c 11 80       	add    $0x80118c00,%eax
801097bf:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	return MAX_CONTAINERS;
}

void container_init(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801097c6:	ff 45 fc             	incl   -0x4(%ebp)
801097c9:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
801097cd:	0f 8e ff fe ff ff    	jle    801096d2 <container_init+0x12>
		containers[i].max_mem = 300;
		containers[i].curr_proc = 1;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
801097d3:	c9                   	leave  
801097d4:	c3                   	ret    

801097d5 <container_reset>:

void container_reset(int vc_num){
801097d5:	55                   	push   %ebp
801097d6:	89 e5                	mov    %esp,%ebp
801097d8:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, "");
801097db:	8b 55 08             	mov    0x8(%ebp),%edx
801097de:	89 d0                	mov    %edx,%eax
801097e0:	01 c0                	add    %eax,%eax
801097e2:	01 d0                	add    %edx,%eax
801097e4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097eb:	01 d0                	add    %edx,%eax
801097ed:	c1 e0 02             	shl    $0x2,%eax
801097f0:	83 c0 10             	add    $0x10,%eax
801097f3:	05 00 8c 11 80       	add    $0x80118c00,%eax
801097f8:	83 c0 08             	add    $0x8,%eax
801097fb:	c7 44 24 04 b4 a1 10 	movl   $0x8010a1b4,0x4(%esp)
80109802:	80 
80109803:	89 04 24             	mov    %eax,(%esp)
80109806:	e8 5e f8 ff ff       	call   80109069 <strcpy>
	containers[vc_num].max_proc = 4;
8010980b:	8b 55 08             	mov    0x8(%ebp),%edx
8010980e:	89 d0                	mov    %edx,%eax
80109810:	01 c0                	add    %eax,%eax
80109812:	01 d0                	add    %edx,%eax
80109814:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010981b:	01 d0                	add    %edx,%eax
8010981d:	c1 e0 02             	shl    $0x2,%eax
80109820:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109825:	c7 40 04 04 00 00 00 	movl   $0x4,0x4(%eax)
	containers[vc_num].max_disk = 100;
8010982c:	8b 55 08             	mov    0x8(%ebp),%edx
8010982f:	89 d0                	mov    %edx,%eax
80109831:	01 c0                	add    %eax,%eax
80109833:	01 d0                	add    %edx,%eax
80109835:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010983c:	01 d0                	add    %edx,%eax
8010983e:	c1 e0 02             	shl    $0x2,%eax
80109841:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109846:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
	containers[vc_num].max_mem = 300;
8010984d:	8b 55 08             	mov    0x8(%ebp),%edx
80109850:	89 d0                	mov    %edx,%eax
80109852:	01 c0                	add    %eax,%eax
80109854:	01 d0                	add    %edx,%eax
80109856:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010985d:	01 d0                	add    %edx,%eax
8010985f:	c1 e0 02             	shl    $0x2,%eax
80109862:	05 00 8c 11 80       	add    $0x80118c00,%eax
80109867:	c7 00 2c 01 00 00    	movl   $0x12c,(%eax)
	containers[vc_num].curr_proc = 1;
8010986d:	8b 55 08             	mov    0x8(%ebp),%edx
80109870:	89 d0                	mov    %edx,%eax
80109872:	01 c0                	add    %eax,%eax
80109874:	01 d0                	add    %edx,%eax
80109876:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010987d:	01 d0                	add    %edx,%eax
8010987f:	c1 e0 02             	shl    $0x2,%eax
80109882:	05 10 8c 11 80       	add    $0x80118c10,%eax
80109887:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
	containers[vc_num].curr_disk = 0;
8010988d:	8b 55 08             	mov    0x8(%ebp),%edx
80109890:	89 d0                	mov    %edx,%eax
80109892:	01 c0                	add    %eax,%eax
80109894:	01 d0                	add    %edx,%eax
80109896:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010989d:	01 d0                	add    %edx,%eax
8010989f:	c1 e0 02             	shl    $0x2,%eax
801098a2:	05 10 8c 11 80       	add    $0x80118c10,%eax
801098a7:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	containers[vc_num].curr_mem = 0;
801098ae:	8b 55 08             	mov    0x8(%ebp),%edx
801098b1:	89 d0                	mov    %edx,%eax
801098b3:	01 c0                	add    %eax,%eax
801098b5:	01 d0                	add    %edx,%eax
801098b7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098be:	01 d0                	add    %edx,%eax
801098c0:	c1 e0 02             	shl    $0x2,%eax
801098c3:	05 00 8c 11 80       	add    $0x80118c00,%eax
801098c8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
801098cf:	c9                   	leave  
801098d0:	c3                   	ret    
